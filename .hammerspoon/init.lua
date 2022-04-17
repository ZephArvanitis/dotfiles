-- Reload config each time a file is edited
-- hs.loadSpoon("ReloadConfiguration")
-- spoon.ReloadConfiguration:start()
hs.alert.show("Loaded config")
-- Reload config
hs.hotkey.bind({"alt"}, "R", function()
    hs.reload()
end)

hs.hotkey.bind({"cmd"}, "J", function()
  hs.alert.show("Hello world!")
  hs.eventtap.keyStroke({"ctrl", "alt"}, "A")
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "G", function()
    hs.alert.show(hs.application.frontmostApplication())
  for k, v in pairs(hs.application.runningApplications()) do
      if string.match(str, "Code") then
          hs.alert.show(v)
      end
  end
  hs.alert.show(hs.keycodes.methods())
  local batinfo = hs.battery
end)

-- Window tiling!
-- Left side
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

-- Right side
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

-- Full screen
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

-- Focus the last used window.
local function focusLastFocused()
    local wf = hs.window.filter
    local lastFocused = wf.defaultCurrentSpace:getWindows(wf.sortByFocusedLast)
    if #lastFocused > 0 then lastFocused[1]:focus() end
end

-- Shortcut jumper
require("shortcutjumper")
hs.hotkey.bind({"alt"}, "J", function()
    shortcutChooser.show()
end)

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

-- Focus (or launch) applications:
function launchOrFail(appName)
  local success = hs.application.launchOrFocus(appName)
  if (not success) then
    hs.alert.show("Unable to find app " .. appName)
  end
end

function bindKeyToApplication(key, applicationName)
    hs.hotkey.bind({'alt'}, key, function()
        launchOrFail(applicationName)
    end)
end

bindKeyToApplication("1", "1Password 7")
-- A reserved for screen placement


-- D reserved for screen placement


bindKeyToApplication("G", "Safari")
bindKeyToApplication("H", "Google Chrome")

-- J reserved for shortcut jumper

bindKeyToApplication("L", "Calendar")




bindKeyToApplication("Q", "/Applications/QGIS3.10.app")
-- R reserved for refreshing config

bindKeyToApplication("T", "iTerm")

bindKeyToApplication("V", "Visual Studio Code")

-- X reserved for screen placement
bindKeyToApplication("Y", "TiddlyDesktop")

