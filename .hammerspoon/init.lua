hs.alert("Loaded config")
-- Reload config
hs.hotkey.bind({"alt"}, "R", function()
  hs.reload()
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
hs.hotkey.bind({"alt"}, "T", function()
  hs.application.launchOrFocus("iTerm")
end)

hs.hotkey.bind({"alt"}, "G", function()
  hs.application.launchOrFocus("Safari")
end)

hs.hotkey.bind({"alt"}, "O", function()
  hs.application.launchOrFocus("Zoom.us")
end)

hs.hotkey.bind({"alt"}, "Z", function()
  hs.application.launchOrFocus("Zendesk")
end)

hs.hotkey.bind({"alt"}, "H", function()
  hs.application.launchOrFocus("Google Chrome")
end)

hs.hotkey.bind({"alt"}, "L", function()
  hs.application.launchOrFocus("Google Calendar")
end)

hs.hotkey.bind({"alt"}, "K", function()
  hs.application.launchOrFocus("Slack")
end)

hs.hotkey.bind({"alt"}, "W", function()
  hs.application.launchOrFocus("/Applications/TiddlyDesktop.app")
end)

hs.hotkey.bind({"alt"}, "N", function()
  hs.application.launchOrFocus("Asana")
end)

hs.hotkey.bind({"alt"}, "V", function()
  hs.application.launchOrFocus("DCV Viewer")
end)

hs.hotkey.bind({"alt"}, "1", function()
  hs.application.launchOrFocus("1Password 7")
end)
