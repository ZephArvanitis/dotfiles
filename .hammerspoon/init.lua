hs.alert("Loaded config")
-- Reload config
hs.hotkey.bind({"alt"}, "R", function()
  hs.reload()
end)

require("util")
require("shortcutjumper")

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

hs.hotkey.bind({"alt"}, "J", function()
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

bindKeyToApplication("F", "Figma")
bindKeyToApplication("G", "Safari")
bindKeyToApplication("H", "Google Chrome")

-- J is reserved for the shortcut jumper
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
