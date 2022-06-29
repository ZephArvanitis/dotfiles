-- from https://stackoverflow.com/a/11671820, thank you!
function map(tbl, f)
    local t = {}
    for k,v in pairs(tbl) do
        t[k] = f(v)
    end
    return t
end

-- from https://www.codegrepper.com/code-examples/lua/lua+split+string+by+space, thank you!
function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

-- from https://stackoverflow.com/a/9080080, thanks!
function intoBinary(n)
    local binNum = ""
    if n ~= 0 then
        while n >= 1 do
            if n %2 == 0 then
                binNum = binNum .. "0"
                n = n / 2
            else
                binNum = binNum .. "1"
                n = (n-1)/2
            end
        end
    else
        binNum = "0"
    end
    return binNum
end

function fromLittleEndian(binaryTable)
    local result = 0
    for index, value in ipairs(binaryTable) do
        result = result + value * (2 ^ (index - 1))
    end
    return result
end

-- Decode a public job/cluster ID into an internal integer ID
function decode(externalID)
    local customAlphabet = 'abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ'
    local obfuscateMapping = {26, 9, 1, 3, 19, 20, 24, 0, 7, 8, 28, 6, 22, 16, 15, 10, 21, 14, 11, 29, 5, 23, 30, 4, 17, 25, 31, 13, 27, 12, 2, 18, 52, 33, 39, 43, 55, 40, 50, 61, 35, 44, 48, 37, 51, 59, 63, 36, 45, 34, 49, 32, 53, 46, 58, 57, 38, 42, 54, 62, 47, 60, 41, 56}
    local n = #customAlphabet
    local mapped = 0
    for index = 1, #externalID do
        local i = index - 1  -- account for one-indexing in lua, vs zero in python
        local c = string.sub(externalID, index, index)
        local custom_index = string.find(customAlphabet, c) - 1 -- one-indexing
        mapped = mapped + custom_index * (n ^ i)
    end
    local mappedBinary = intoBinary(mapped)
    -- well it turns out lua uses floats for everything, which isn't a
    -- problem until you're dealing with ints larger than, say, 1e12. But
    -- here we are, so I'm about to re-hash this algorithm to handle things
    -- literally bit by bit rather than using fast math. :sadpanda:
    local decodedBinary = {}
    for i = 1, 64 do -- 64 is length of obfuscation mapping
        decodedBinary[i] = 0
    end
    for indexPlusOne, value in ipairs(obfuscateMapping) do
        -- check if the value'th least significant digit in the mapped
        -- binary encoding is a 1.
        local valueThBit = string.sub(mappedBinary, value + 1, value + 1)

        -- if so, make the index-th least significant digit in the decoded
        -- value 1
        if valueThBit == '1' then
            decodedBinary[indexPlusOne] = 1
        end
    end
    return fromLittleEndian(decodedBinary)
end

function isExternalID(inputString)
    -- it can be an external ID if it consists only of upper/lowercase
    -- letters
    return string.match(inputString, "%a*") == inputString
end

function isInternalID(inputString)
    -- it's an internal ID if it consists only of digits
    return string.match(inputString, "%d*") == inputString
end

-- shortcut chooser
-- First, remove newlines in the editable file.
os.execute("tr -d '\n' < ~/.hammerspoon/shortcuts.json > ~/.hammerspoon/.shortcuts.json")
os.execute("tr -d '\n' < ~/.hammerspoon/platform-shortcuts.json > ~/.hammerspoon/.platform-shortcuts.json")
local shortcutChoices = {}
for _, shortcut in ipairs(hs.json.decode(io.open(".shortcuts.json"):read())) do
    table.insert(shortcutChoices,
        {text=shortcut['name'],
            subText=table.concat(shortcut['kwds'], ", "),
            page=shortcut['page'],
            application=shortcut['application'],
            querystring=shortcut['querystring'],
            acceptsIDs=shortcut['acceptsIDs']
        })
end
local platforms = {
    ["PROD"] = "https://platform.rescale.com",
    ["ITAR"] = "https://itar.rescale.com",
    ["EU"] = "https://eu.rescale.com",
    ["KR"] = "https://kr.rescale.com",
    ["JP"] = "https://platform.rescale.jp",
    ["ST"] = "https://platform-stage.rescale.com",
    ["DEV"] = "https://platform-dev.rescale.com",
    ["GOVST"] = "https://itar-staging.rescale.com",
    ["ALLPR"] = "https://kr.rescale.com;https://platform.rescale.jp;https://platform.rescale.com;https://itar.rescale.com;https://eu.rescale.com"
}
for _, shortcut in ipairs(hs.json.decode(io.open(".platform-shortcuts.json"):read())) do
    for platformName, baseurl in pairs(platforms) do
        shortcut_url_unescaped = shortcut['page']
        -- for some reason shortcut_url:gsub doesn't work here, but
        -- string.gsub does
        shortcut_url = string.gsub(shortcut_url_unescaped, '%%', '%%%%')
        table.insert(shortcutChoices,
            {text=platformName..' '..shortcut['name'],
                subText=table.concat(map(shortcut['kwds'], function (kwd) return string.lower(platformName)..kwd end), ", "),
                -- account for multi-url platforms like allprods
                page=string.gsub(baseurl, ';', shortcut_url .. ';') .. shortcut_url_unescaped,
                application=shortcut['application'],
                querystring=shortcut['querystring'],
                acceptsIDs=shortcut['acceptsIDs']
            })
    end
end

function openURL(uses_querystring, acceptsIDs, url, app, query)
    if uses_querystring then
        local query_words = split(query, ' ')
        table.remove(query_words, 1)
        local querystring = table.concat(query_words, ' ')
        if acceptsIDs and isExternalID(querystring) then
            querystring = string.format("%.0f", decode(querystring))
        end
        url = url:gsub("%%s", querystring)
    end
    local oldClipboard = hs.pasteboard.getContents()
    hs.pasteboard.setContents(url)
    hs.application.launchOrFocus(app)
    -- new tab, fairly cross-browser
    hs.eventtap.keyStroke({"cmd"}, "T")
    -- paste (much faster than using keyStrokes with a long string)
    hs.eventtap.keyStroke({"cmd"}, "V")
    hs.eventtap.keyStroke({}, "return")
    -- reset old clipboard
    hs.pasteboard.setContents(oldClipboard)
end

-- Create the shortcutChooser.
shortcutChooser = nil
shortcutChooser = hs.chooser.new(function(choice)
    if not choice then focusLastFocused(); return end
    -- local query = string.lower(shortcutChooser:query())
    local query = shortcutChooser:query()

    local uses_querystring = choice["querystring"] ~= nil
    local acceptsIDs = choice["acceptsIDs"] ~= nil
    local url = choice["page"]
    local app = choice["application"]

    -- handle multi-url situations
    -- multiurl = string.find(word, ";", true) ~= nil
    -- if multiurl
    local urls = split(url, ';')
    for i, url in pairs(urls) do
        openURL(uses_querystring, acceptsIDs, url, app, query)
    end

end)
shortcutChooser:queryChangedCallback(function()
    -- adapted from:
    -- https://github.com/Hammerspoon/hammerspoon/issues/782#issuecomment-224086987

    -- this appears to get the updated query each time it's called, hooray!
    -- make this case-insensitive search
    local query = string.lower(shortcutChooser:query())
    -- and escape any special chars (comes up most often for `-`)
    -- TODO: figure out how to escape special chars in general
    query = query:gsub("%-", "%%-")
    if query == '' then
        -- fully populated list if no query (this is speedy)
        shortcutChooser:choices(shortcutChoices)
    else
        local choices = {}
        -- remember, lua uses one-indexing :sadpanda:
        local first_query_word = split(query, ' ')[1]

        -- local queries = ss.u.strSplit(query, ' ')

        for _, aChoice in pairs(shortcutChoices) do
            -- for hits in general, check query against text and kwds
            local check_str = aChoice["text"]..", "..aChoice["subText"]
            check_str = string.lower(check_str)
            local matches_at_all = string.match(check_str, query)

            -- additionally, match those with querystring=True iff the
            -- first *word* of the query matches one of the kwds for the
            -- choice. (Luckily based on the wrapping if statement here we
            -- can always assume we have at least one character, so no null
            -- strings)
            local matches_querystring = string.match(aChoice["subText"], first_query_word) and aChoice["querystring"] ~= nil
            if matches_at_all or matches_querystring then
                table.insert(choices, aChoice)
            end
        end

        shortcutChooser:choices(choices)
    end
end)


shortcutChooser:searchSubText(true)
shortcutChooser:choices(shortcutChoices)

shortcutChooser:rows(5)
shortcutChooser:bgDark(true)

