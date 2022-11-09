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


hs.hotkey.bind({"cmd","alt"}, "J", nil, function()
    hs.alert('rawr')
end)

-- function applicationWatcher(appName, eventType, appObject)
--     if (appName == "Safari" or appName == "Google Chrome") then
--         if (eventType == hs.application.watcher.activated) then
--             if (moveToZendeskBinding ~= nil) then
--                 moveToZendeskBinding:enable()
--             else
--                 moveToZendeskBinding = hs.hotkey.bind({"alt", "shift"}, "Z", moveToZendesk)
--             end
--         elseif (eventType == hs.application.watcher.deactivated) then
--             if (moveToZendeskBinding ~= nil) then
--                 moveToZendeskBinding:disable()
--             end
--         end
--     end
-- end
-- local appWatcher = hs.application.watcher.new(applicationWatcher)
-- appWatcher:start()

-- update slack status + team with info about being away for a minute
function steppingAway(channel, messages, statuses)
  hs.application.launchOrFocus("Slack")
  hs.eventtap.keyStroke({"cmd"}, "K")

  local oldClipboard = hs.pasteboard.getContents()
  -- jump to puppycorn private channel
  -- paste (much faster than using keyStrokes with a long string)
  hs.pasteboard.setContents(channel)
  hs.eventtap.keyStroke({"cmd"}, "V")
  hs.eventtap.keyStroke({}, "return")

  -- save previous draft
  hs.eventtap.keyStroke({"cmd"}, "A")
  hs.eventtap.keyStroke({"cmd"}, "X")
  local oldMessage = hs.pasteboard.getContents()

  -- update status
  local statusUpdateCommand = "/status " .. statuses[math.random(#statuses)]
  hs.pasteboard.setContents(statusUpdateCommand)
  hs.eventtap.keyStroke({"cmd"}, "V")
  hs.eventtap.keyStroke({}, "return")

  -- message that I'll be out for a minute
  local brbMessage = messages[ math.random( #messages ) ]
  hs.pasteboard.setContents(brbMessage)
  hs.eventtap.keyStroke({"cmd"}, "V")
  -- but leave hitting the "enter" key to the user pls

  -- paste old draft if any, otherwise old clipboard
  if oldMessage == nil or oldMessage == '' then
    hs.pasteboard.setContents(oldClipboard)
  else
    hs.pasteboard.setContents(oldMessage)
  end
end

-- shortcuts to respond
function medicalCall()
  messages = {"Hey team, stepping out for about an hour",
              "gotta step away for a bit, back soon",
              "I'm heading out for an hour or so, see you all after that",
              "I'll be out for about an hour",
              "hey team, stepping out for a short bit :stethoscope:",
              "I'll be out for about an hour :ambulance:"}
  statuses = {":speech_balloon: back shortly",
              ":brb: back in an hour"}
  channel = "puppycorn-private"
  steppingAway(channel, messages, statuses)
end

function fireCall()
  messages = {"Hey team, stepping out for a couple hours, will catch up once I'm back",
              "gotta step away for a bit, back in a while :fire:",
              "I'll be out for about two hours",
              "Gotta run, will catch up once I'm back :fire_engine:"}
  statuses = {":speech_balloon: afk, back in a couple hours",
              ":fire: back in a couple hours",
              ":fire_engine: afk, back in a couple hours"}
  channel = "puppycorn-private"
  steppingAway(channel, messages, statuses)
end

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

bindKeyToApplication("1", "1Password")
-- A is reserved for screen placement
bindKeyToApplication("B", "Obsidian")

-- D is reserved for screen placement

-- F is for fire calls
bindKeyToApplication("G", "Safari")
bindKeyToApplication("H", "Google Chrome")

-- J is reserved for the shortcut jumper
bindKeyToApplication("K", "Slack")
bindKeyToApplication("L", "Google Calendar")
-- M is for medical calls

bindKeyToApplication("O", "Zoom.us")


-- R is reserved for refreshing hammerspoon

bindKeyToApplication("T", "iTerm")

bindKeyToApplication("V", "Visual Studio Code")

-- X is reserved for screen placement


