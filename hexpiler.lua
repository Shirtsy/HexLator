local version = "0.9.3"

--controls all print outputs
local gVerb = true

local function vPrint(s)
    if gVerb == true then
        print(s)
    end
end

local function getRunningPath()
    local runningProgram = shell.getRunningProgram()
    local programName = fs.getName(runningProgram)
    return runningProgram:sub( 1, #runningProgram - #programName )
end

--load symbol-registry.json
local srFile = fs.open(getRunningPath() .. "symbol-registry.json", "r")
local srRaw = textutils.unserialiseJSON(srFile.readAll())
if not srFile then
    vPrint("Could not find symbol-registry.json in the current directory")
    return
end

-- Strips all non-alphanumerics plus underscores
local function stripString(iString)
    local rString,_ = string.gsub(iString," ","_")
    rString,_ = string.gsub(rString,"-","n")
    rString,_ = string.gsub(rString,"+","p")
    rString,_ = string.gsub(rString,"[^%w_]+","")
    return rString
end

--load raw symbol registry translation table
local symbolRegistry = {}
for k,v in pairs(srRaw) do
    local sName =  k --stripString(k)
    symbolRegistry[sName] = {
        ["angles"] = v["pattern"],
        ["startDir"] = v["direction"],
    }
end
symbolRegistry["{"] = symbolRegistry["Introspection"]
symbolRegistry["}"] = symbolRegistry["Retrospection"]
symbolRegistry[">>"] = symbolRegistry["Flock's Disintegration"]

local strippedRegistry = {}
for k,v in pairs(srRaw) do
    local sName =  stripString(k)
    strippedRegistry[sName] = {
        ["angles"] = v["pattern"],
        ["startDir"] = v["direction"],
    }
end
strippedRegistry["{"] = strippedRegistry["Introspection"]
strippedRegistry["}"] = strippedRegistry["Retrospection"]
strippedRegistry[">>"] = strippedRegistry["Flocks_Disintegration"]

-- Given a string and start location, returns everything within a balanced set of parentheses
local function getBalancedParens(s, startLoc)
    local str = string.match(s, "(%b())", startLoc)
    return string.sub(str, 2, -2)
end

-- Given a string, returns a table of strings with commas as delim
local function splitCommas(str)
    local valTable = {}
    local i = 1
    for k,_ in string.gmatch(str, "([^,]+)") do
        valTable[i] = k
        i = i + 1
    end
    return valTable
end

-- All identifiers and associated functions to correctly grab and format data given the raw string and a token
local identRegistry = {
    ["@null"] = function()
        return {["null"] = true}
    end,
    ["@garbage"] = function()
        return {["garbage"] = true}
    end,
    ["@true"] = function()
        return true
    end,
    ["@false"] = function()
        return false
    end,
    ["@iota_type"] = function(s, token)
        local str = getBalancedParens(s, token["start"])
        return {["iotaType"] = str}
    end,
    ["@entity_type"] = function(s, token)
        local str = getBalancedParens(s, token["start"])
        return {["entityType"] = str}
    end,
    ["@entity"] = function(s, token)
        local str = getBalancedParens(s, token["start"])
        return {["uuid"] = str}
    end,
    ["@pattern"] = function(s, token)
        local str = getBalancedParens(s, token["start"])
        local valTable = splitCommas(str)
        local returnTable =  {
            ["startDir"] = valTable[1],
            ["angles"] = valTable[2],
        }
        return returnTable
    end,
    ["@gate"] = function(s, token)
        local str = getBalancedParens(s, token["start"])
        return {["gate"] = str}
    end,
    ["@vec"] = function(s, token)
        local str = getBalancedParens(s, token["start"])
        local valTable = splitCommas(str)
        local returnTable =  {
            ["x"] = tonumber(valTable[1]),
            ["y"] = tonumber(valTable[2]),
            ["z"] = tonumber(valTable[3])
        }
        return returnTable
    end,
    ["@matrix"] = function(s, token)
        local str = getBalancedParens(s, token["start"])
        local valTable = splitCommas(str)
        local returnTable =  {
            ["col"] = tonumber(valTable[1]),
            ["row"] = tonumber(valTable[2]),
            ["matrix"] = tonumber(valTable[3])
        }
        return returnTable
    end,
    ["@mote"] = function(s, token)
        local str = getBalancedParens(s, token["start"])
        local valTable = splitCommas(str)
        local returnTable =  {
            ["moteUuid"] = tonumber(valTable[1]),
            ["itemID"] = tonumber(valTable[2])
        }
        return returnTable
    end,
    ["@num"] = function(s, token)
        local str = getBalancedParens(s, token["start"])
        return tonumber(str)
    end,
    ['@str'] = function(s, token)
        local str = getBalancedParens(s, token["start"])
        return str
    end,
    ["%["] = true,
    ["%]"] = true,
}

local stringProccessRegistry = {
    ["#file"] = function(s, token)
        local filenames = getBalancedParens(s, token["start"])
        local valTable = splitCommas(filenames)
        local insertStr = ""
        for i,fName in ipairs(valTable) do
            --strips spaces out of filename
            fName = string.gsub(fName," ","")
            vPrint("Inserting "..getRunningPath()..fName)
            local file = fs.open(getRunningPath()..fName, "r")
            local content = file.readAll()
            file.close()
            insertStr = insertStr..content
        end
        local firstChar = token["start"]
        local lastChar = token["end"] + #filenames + 2
        local out =  s:sub(1,firstChar-1).."\n"..insertStr.."\n"..s:sub(lastChar+1)

        --local debug = fs.open(getRunningPath().."debug", "w")
        --debug.write(out)
        --debug.close()

        return out
    end,
}

-- Runs a function associated with a token's 'content' field from a given reg table
local function runTokenFunc(s, registry, token)
    local tokenReturn = registry[token["content"]]
    if tokenReturn ~= nil and tokenReturn ~= true then
        token["value"] = tokenReturn(s, token)
        return token["value"]
    end
end

-- Gets symbol data associated with a token's 'content' field from a given reg table
local function setSymbolValue(s, registry, token)
    token["value"] = {
        ["startDir"] = registry[token["content"]]["startDir"],
        ["angles"] = registry[token["content"]]["angles"]
    }
end

-- Walks through a string and checks for presence of tokens from registry and initializes them
local function tokenSearch(s, registry)
    local tokens = {}
    for k,_ in pairs(registry) do
        local i, j = string.find(s, k)
        while i do
            if not tokens[i] or j > tokens[i]["end"] then
                tokens[i] = {
                    ["start"] = i,
                    ["end"] = j,
                    ["content"] = k,
                    ["value"] = nil
                }
            end
            i, j = string.find(s, k, i+1)
        end
    end
    return tokens
end

-- Sorts a list a tokens to occur in the order of their appearance in the raw string
local function sortTokens(t)
    local keys = {}
    local returnTable = {}
    for k,_ in pairs(t) do
        table.insert(keys, k)
    end
    table.sort(keys)
    for i, k in ipairs(keys) do
        returnTable[i] = t[k]
    end
    return returnTable
end

-- Accepts a table of tables, returns a table that contains all key/value pairs
local function combineTables(tTable)
    local final = {}
    for _,v in pairs(tTable) do
        for k2,v2 in pairs(v) do
            final[k2] = v2
        end
    end
    return final
end

local myStack = {{}}
local stack = {
    push = function(e)
        table.insert(myStack, e)
    end,
    pop = function()
        return table.remove(myStack)
    end,
    top = function()
        return myStack[#myStack]
    end
}

local function dump_table(t,indent)
    indent = indent or 0    
    for key, value in pairs(t) do
        if type(value) == "table" then
            vPrint(string.rep("  ", indent) .. key .. " = {")
            dump_table(value, indent + 1)
            vPrint(string.rep("  ", indent) .. "}")
        else
            vPrint(string.rep("  ", indent) .. key .. " = " .. tostring(value))
        end
    end
end

local function compileChunk(tokens)
    for k,v in pairs(tokens) do
        if v["content"] == "%[" then
            vPrint("List start...")
            stack.push({})
        elseif v["content"] == "%]" then
            vPrint("... list end.")
            local j = stack.pop()
            local t = stack.top()
            table.insert(t, j)
        else
            local t = stack.top()
            table.insert(t, v["value"])
            if gVerb == true then print(k,v["start"],v["end"]," ",v["content"], v["value"]) end
        end
    end
    --dump_table(myStack,0)
    --dump_table(output,1)
    local returnVal = stack.pop()
    stack.push({})
    return returnVal
end

local function compile(str, stripped, verbose)
    if verbose ~= nil then
        gVerb = verbose
    end
    vPrint("Compiling...")
    local reg
    if stripped == true then
        reg = strippedRegistry
    else
        reg = symbolRegistry
    end

    -- Strip line comments from file
    str = string.gsub(str, "//.-\n", "")

    -- Replace string with version of itself with the specified file contents inside instead
    vPrint("Parsing string processes...")
    for _ in pairs(tokenSearch(str, stringProccessRegistry)) do
        local search = sortTokens(tokenSearch(str, stringProccessRegistry))
        local single = table.remove(search)
        str = runTokenFunc(str, stringProccessRegistry, single)
    end

    local searches = {}

    vPrint("Parsing identifiers...")
    searches["identifiers"] = tokenSearch(str, identRegistry)
    for _,v in pairs(searches["identifiers"]) do
        runTokenFunc(str, identRegistry, v)
    end

    vPrint("Parsing symbols...")
    searches["symbols"] = tokenSearch(str, reg)
    for _,v in pairs(searches["symbols"]) do
        setSymbolValue(str, reg, v)
    end
    local tokens = sortTokens(combineTables(searches))
    local output = compileChunk(tokens)
    --print(#output)
    return output
end

local function writeToFocus(tab)
    --dump_table(tab,1)
    local focal_port = peripheral.find("focal_port")
    if not focal_port then
        vPrint("Cannot write! No focal port found.")
    elseif not focal_port.hasFocus() then
        vPrint("Cannot write! No focus found.")
    elseif not focal_port.canWriteIota() then
        vPrint("Cannot write! This won't compile!")
    else
        focal_port.writeIota(tab)
        vPrint("Compiled to focus!")
    end
end

local function test()
    local file = fs.open(getRunningPath() .. "example.hexpattern", "r")
    local contents = file.readAll()
    file.close()
    writeToFocus(compile(contents))
end

return {
    compile = compile,
    writeToFocus = writeToFocus,
    symbolRegistry = symbolRegistry,
    identRegistry = identRegistry
}