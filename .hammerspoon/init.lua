hs.alert("Loaded config")
-- Reload config
hs.hotkey.bind({"alt"}, "R", function()
  hs.reload()
end)

-- Focus the last used window.
local function focusLastFocused()
    local wf = hs.window.filter
    local lastFocused = wf.defaultCurrentSpace:getWindows(wf.sortByFocusedLast)
    if #lastFocused > 0 then lastFocused[1]:focus() end
end

-- Emoji chooser
-- taken verbatim from https://aldur.github.io/articles/hammerspoon-emojis/
-- thank you!
--
-- NOTE: depends upon a directory of emojis, which can be obtained by unzipping
-- the file here: https://aldur.github.io/articles/hammerspoon-emojis/
local emoji_choices = {}
for _, emoji in ipairs(hs.json.decode(io.open("emojis/emojis.json"):read())) do
    table.insert(emoji_choices,
        {text=emoji['name'],
            subText=table.concat(emoji['kwds'], ", "),
            image=hs.image.imageFromPath("emojis/" .. emoji['id'] .. ".png"),
            chars=emoji['chars']
        })
end

-- Create the emojiChooser.
-- On selection, copy the emoji and type it into the focused application.
local emojiChooser = hs.chooser.new(function(choice)
    if not choice then focusLastFocused(); return end
    hs.pasteboard.setContents(choice["chars"])
    focusLastFocused()
    hs.eventtap.keyStrokes(hs.pasteboard.getContents())
end)

emojiChooser:searchSubText(true)
emojiChooser:choices(emoji_choices)

emojiChooser:rows(5)
emojiChooser:bgDark(true)

hs.hotkey.bind({"cmd", "alt"}, "E", function() emojiChooser:show() end)

-- shortcut chooser
-- First, remove newlines in the editable file.
os.execute("tr -d '\n' < ~/.hammerspoon/shortcuts.json > ~/.hammerspoon/.shortcuts.json")
local shortcutChoices = {}
for _, shortcut in ipairs(hs.json.decode(io.open(".shortcuts.json"):read())) do
    table.insert(shortcutChoices,
        {text=shortcut['name'],
            subText=table.concat(shortcut['kwds'], ", "),
            page=shortcut['page'],
            application=shortcut['application'],
            querystring=shortcut['querystring']
        })
end

-- from https://stackoverflow.com/a/11671820, thank you!
function map(tbl, f)
    local t = {}
    for k,v in pairs(tbl) do
        t[k] = f(v)
    end
    return t
end

-- from https://stackoverflow.com/a/641993, thank you!
function shallow_copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end


-- adapted from https://www.reddit.com/r/lua/comments/lccolr/comment/glzhd0u/, thank you!
local function any(t)
    for _, v in pairs(t) do
        if v then return true end
    end

    return false
end

-- from https://www.codegrepper.com/code-examples/lua/lua+split+string+by+space, thank you!
local function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

-- Create the shortcutChooser.
-- On selection, copy the emoji and type it into the focused application.
local shortcutChooser = nil
shortcutChooser = hs.chooser.new(function(choice)
    if not choice then focusLastFocused(); return end
    local query = string.lower(shortcutChooser:query())

    local uses_querystring = choice["querystring"] ~= nil
    local url = choice["page"]
    local app = choice["application"]

    local oldClipboard = hs.pasteboard.getContents()
    if uses_querystring then
        local query_words = split(query, ' ')
        table.remove(query_words, 1)
        local querystring = table.concat(query_words, ' ')
        url = url:gsub("%%s", querystring)
    end
    hs.pasteboard.setContents(url)
    hs.application.launchOrFocus(app)
    -- new tab, fairly cross-browser
    hs.eventtap.keyStroke({"cmd"}, "T")
    -- paste (much faster than using keyStrokes with a long string)
    hs.eventtap.keyStroke({"cmd"}, "V")
    hs.eventtap.keyStroke({}, "return")
    -- reset old clipboard
    hs.pasteboard.setContents(oldClipboard)
end)
shortcutChooser:queryChangedCallback(function()
    -- adapted from:
    -- https://github.com/Hammerspoon/hammerspoon/issues/782#issuecomment-224086987

    -- this appears to get the updated query each time it's called, hooray!
    local query = string.lower(shortcutChooser:query())
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

hs.hotkey.bind({"cmd", "alt"}, "S", function()
    shortcutChooser:show()
end)


-- Move a zendesk ticket from a browser to the zendesk "application"

-- Let's do some application-specific stuff
local moveToZendeskBinding = nil
function moveToZendesk()
    local win = hs.window.focusedWindow()
    local clipboard = hs.pasteboard.getContents()
    hs.eventtap.keyStroke({"cmd"}, "L")
    hs.eventtap.keyStroke({"cmd"}, "C")
    hs.eventtap.keyStroke({}, "ESCAPE")
    hs.eventtap.keyStroke({}, "ESCAPE")
    local url = hs.pasteboard.getContents()
    local match = string.match(url, "rescale.zendesk.com/agent/tickets/%d+")
    hs.pasteboard.setContents(clipboard)
    if (match) then
        hs.alert("It's a zendesk link!")
        local ticketID = string.match(match, "(%d+)")
        hs.application.launchOrFocus("Zendesk")
        -- for reasons beyond my ken, sending this keyStroke doesn't work.
        -- Is very sad :'(
        hs.eventtap.keyStroke({"ctrl", "alt"}, "F", 500000)
        hs.eventtap.keyStrokes(ticketID)
        hs.eventtap.keyStroke({}, "ENTER")
        hs.eventtap.keyStroke({}, "ENTER")
    else
        -- hs.alert("Non-zendesk link, nop nop nop")
    end
end

-- attempting to debug keystroke sending, which works in some places but not others
-- hs.hotkey.bind({"cmd"}, "J", nil, function()
--     hs.alert('hello darkness')
--     hs.eventtap.event.newKeyEvent(hs.keycodes.map.ctrl, true):post()
--     hs.alert('cmd')
--     hs.eventtap.event.newKeyEvent(hs.keycodes.map.alt, true):post()
--     hs.alert('alt')
--     hs.eventtap.event.newKeyEvent("f", true):post()
--     hs.alert('u')
--     hs.eventtap.event.newKeyEvent("f", false):post()
--     hs.alert('u')
--     hs.eventtap.event.newKeyEvent(hs.keycodes.map.alt, false):post()
--     hs.alert('alt')
--     hs.eventtap.event.newKeyEvent(hs.keycodes.map.ctrl, false):post()
--     hs.alert('cmd')
--     -- hs.eventtap.keyStroke({"alt", "cmd"}, "F")
-- end)
--
hs.hotkey.bind({"cmd","alt"}, "J", nil, function()
    hs.alert('rawr')
    testCallbackFn = function(result) print("Callback Result: " .. result) end
    hs.dialog.textPrompt("Main message.", "Please enter something:")
    hs.dialog.alert(100, 100, testCallbackFn, "Message", "Informative Text", "Button One", "Button Two", "NSCriticalAlertStyle")
    hs.dialog.alert(200, 200, testCallbackFn, "Message", "Informative Text", "Single Button")
    hs.alert('rawr2')
end)

function applicationWatcher(appName, eventType, appObject)
    if (appName == "Safari" or appName == "Google Chrome") then
        if (eventType == hs.application.watcher.activated) then
            if (moveToZendeskBinding ~= nil) then
                moveToZendeskBinding:enable()
            else
                moveToZendeskBinding = hs.hotkey.bind({"alt", "shift"}, "Z", moveToZendesk)
            end
        elseif (eventType == hs.application.watcher.deactivated) then
            if (moveToZendeskBinding ~= nil) then
                moveToZendeskBinding:disable()
            end
        end
    end
end
local appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

-- Moving windows around
hs.hotkey.bind({"alt"}, "A", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

hs.hotkey.bind({"alt"}, "D", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + max.w / 2
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

hs.hotkey.bind({"alt"}, "X", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w
  f.h = max.h
  win:setFrame(f)
end)

-- Send keystrokes
-- function keyStrokes(str)
--   return function()
--       hs.eventtap.keyStrokes(str)
--   end
-- end
-- hs.hotkey.bind({"alt", "cmd"}, "L", keyStrokes("console.log("))

-- Focus applications
function bindKeyToApplication(key, applicationName)
    hs.hotkey.bind({"alt"}, key, function()
        hs.application.launchOrFocus(applicationName)
    end)
end

bindKeyToApplication("1", "1Password 7")
-- A is reserved for screen placement

bindKeyToApplication("C", "Zendesk Chat")
-- D is reserved for screen placement


bindKeyToApplication("G", "Safari")
bindKeyToApplication("H", "Google Chrome")


bindKeyToApplication("K", "Slack")
bindKeyToApplication("L", "Google Calendar")

bindKeyToApplication("N", "Asana")
bindKeyToApplication("O", "Zoom.us")


-- R is reserved for refreshing hammerspoon

bindKeyToApplication("T", "iTerm")

bindKeyToApplication("V", "Visual Studio Code")
bindKeyToApplication("W", "/Applications/TiddlyDesktop.app")
-- X is reserved for screen placement

bindKeyToApplication("Z", "Zendesk")
