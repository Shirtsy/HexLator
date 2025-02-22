local function get_json_value(json_str, key)
    -- Escape special characters in the key
    key = key:gsub("([%[%]%(%)%.%%%+%-%*%?%^%$])", "%%%1")
    -- Match the key and extract the value
    local pattern = '"' .. key .. '"%s*:%s*"(.-)"'
    return json_str:match(pattern)
end

return {
    get = get_json_value
}