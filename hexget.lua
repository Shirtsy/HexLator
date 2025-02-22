local function printUsage()
    local programName = arg[0] or fs.getName(shell.getRunningProgram())
    print("Usage:")
    print(programName .. " <url>")
end

local version = "HexGet v1.0"
print(version)
print("-------------")
sleep(0.5)

local tArgs = { ... }

local debug = false
if tArgs[1] == "debug" then
    table.remove(tArgs, 1)
    debug = true
    print("DEBUG OUTPUT ENABLED")
end

if #tArgs < 1 then
    printUsage()
    return
end

local url = table.remove(tArgs, 1)

if not http then
    printError("hexget requires the http API")
    printError("Set http.enabled to true in CC: Tweaked's config")
    return
end

local function getFilename(sUrl)
    sUrl = sUrl:gsub("[#?].*" , ""):gsub("/+$" , "")
    return sUrl:match("/([^/]+)$")
end

-- local function get(sUrl)
--     -- Check if the URL is valid
--     local ok, err = http.checkURL(url)
--     if not ok then
--         printError(err or "Invalid URL.")
--         return
--     end

--     write("Connecting to " .. sUrl .. "... ")

--     local response = http.get(sUrl , nil , true)
--     if not response then
--         print("Failed.")
--         return nil
--     end

--     print("Success.")

--     local sResponse = response.readAll()
--     response.close()
--     return sResponse or ""
-- end

local github = require("github")
--local res = get(url)
spell_url = github.convert_url(url)
local res = github.api_response(spell_url).content
if not res then return end

local hexlator = require("hexlator")
local stripped = false
local verbose = true
local compiled = hexlator.compile(res, stripped, verbose, debug)
hexlator.writeToFocus(compiled)


return {version = version}