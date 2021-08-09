hs.alert("Loaded config")
-- Reload config
hs.hotkey.bind({"alt"}, "R", function()
  hs.reload()
end)

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
