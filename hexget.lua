local function printUsage()
    local programName = arg[0] or fs.getName(shell.getRunningProgram())
    vPrint("Usage:")
    vPrint(programName .. " <url>")
    vPrint(programName .. " run <url>")
end

local version = "HexGet v1.0"
vPrint(version)
vPrint("-------------")
sleep(0.5)

local tArgs = { ... }

local run = false
if tArgs[1] == "run" then
    table.remove(tArgs, 1)
    run = true
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

local function get(sUrl)
    -- Check if the URL is valid
    local ok, err = http.checkURL(url)
    if not ok then
        printError(err or "Invalid URL.")
        return
    end

    write("Connecting to " .. sUrl .. "... ")

    local response = http.get(sUrl , nil , true)
    if not response then
        vPrint("Failed.")
        return nil
    end

    vPrint("Success.")

    local sResponse = response.readAll()
    response.close()
    return sResponse or ""
end

if run then
    local res = get(url)
    if not res then return end

    local func, err = load(res, getFilename(url), "t", _ENV)
    if not func then
        printError(err)
        return
    end

    local ok, err = pcall(func, table.unpack(tArgs))
    if not ok then
        printError(err)
    end
else
    local res = get(url)
    if not res then return end

    local hexpiler = require("hexpiler")
    local compiled = hexpiler.compile(res)
    hexpiler.writeToFocus(compiled)
end

return {version = version}