-- Reload config each time a file is edited
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()
hs.alert.show("Config reloaded")

-- This is a test
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "H", function()
  hs.alert.show("Hello world!")
  open_discord_for_break()
end)

function do_a_thing()
    hs.alert.show("Did a thing!")
end


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

-- Focus (or launch) applications:
function launchOrFail(appName)
  local success = hs.application.launchOrFocus(appName)
  if (not success) then
    hs.alert.show("Unable to find app " .. appName)
  end
end

hs.hotkey.bind({"alt"}, "G", function()
  launchOrFail("Safari")
end)
hs.hotkey.bind({"alt"}, "L", function()
  launchOrFail("Calendar")
end)
hs.hotkey.bind({"alt"}, "T", function()
  launchOrFail("iTerm")
end)
hs.hotkey.bind({"alt"}, "Q", function()
  launchOrFail("Slack")
end)
hs.hotkey.bind({"alt"}, "V", function()
  launchOrFail("Visual Studio Code")
end)
hs.hotkey.bind({"alt"}, "Y", function()
  launchOrFail("TiddlyDesktop")
end)
hs.hotkey.bind({"alt"}, "Z", function()
  launchOrFail("Azure Data Studio")
end)
hs.hotkey.bind({"alt"}, "I", function()
  launchOrFail("/Applications/QGIS3.10.app")
end)

-- Check email every time I focus thunderbird.
-- For some reason pop3 is slow at getting emails, so we'll just do
-- it manually.
function launch_thunderbird_or_retrieve_zeph_email()
    -- if it's not already open, launch it
    -- For some reason, this causes Thunderbird to open in safe mode. Boooo
    if hs.application.find("Thunderbird") == nil then
        hs.application.launchOrFocus("Thunderbird")
        return
    end
    -- if it *is* already open, load messages
    -- Note: this will fail if it focuses a compose-email window rather
    -- than the main one, but I don't want to always focus the main one
    -- because it's abnormal behavior. So I think it's fine.
    hs.application.launchOrFocus("Thunderbird")
    local thunderbird = hs.appfinder.appFromName("Thunderbird")

    local str_check_email = {"File", "Get New Messages for", "zeph@getsafetycone.com"}

    local check_email = thunderbird:findMenuItem(str_check_email)

    if (check_email) then
        thunderbird:selectMenuItem(str_check_email)
        hs.alert.show("Loading new email")
    else
        hs.alert.show("Unable to load new email for zeph")
    end
end
hs.hotkey.bind({"alt"}, 'M', launch_thunderbird_or_retrieve_zeph_email)

-- Discord-related shortcuts and helpers.
-- Hint: don't be on discord during the day!
function contains(list, x)
    for _, v in pairs(list) do
        if v == x then return true end
    end
    return false
end

-- You shouldn't be on discord at this time!!
function is_discordable_time()
    -- specifically, on weekdays from 8am to 4pm

    local weekdays = {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday"}
    local day_of_week = os.date("%A")
    if not contains(weekdays, day_of_week) then
        -- weekend: all good
        return true
    end

    -- now check if it's between 0800 and 1600
    local function getMinutes(hours,minutes)
        return (hours*60)+minutes
    end

    local value1 = getMinutes(8,0)
    local value2 = getMinutes(16,0)
    local hours = tonumber(os.date("%H"))
    local mins = tonumber(os.date("%M"))
    local currentTime = getMinutes(hours, mins)

    local isBetween = false
    if (currentTime >= value1 and currentTime <= value2) or (currentTime >= value2 and currentTime <= value1) then
        isBetween = true
    end

    return not isBetween
end

local Chars = {}
for Loop = 0, 255 do
   Chars[Loop+1] = string.char(Loop)
end
local String = table.concat(Chars)

local Built = {['.'] = Chars}

local AddLookup = function(CharSet)
   local Substitute = string.gsub(String, '[^'..CharSet..']', '')
   local Lookup = {}
   for Loop = 1, string.len(Substitute) do
       Lookup[Loop] = string.sub(Substitute, Loop, Loop)
   end
   Built[CharSet] = Lookup

   return Lookup
end

function string.random(Length, CharSet)
   -- Length (number)
   -- CharSet (string, optional); e.g. %l%d for lower case letters and digits

   local CharSet = CharSet or '.'

   if CharSet == '' then
      return ''
   else
      local Result = {}
      local Lookup = Built[CharSet] or AddLookup(CharSet)
      local Range = #Lookup

      for Loop = 1,Length do
         Result[Loop] = Lookup[math.random(1, Range)]
      end

      return table.concat(Result)
   end
end

local seconds = 5
local end_function = do_a_thing

function five_second_countdown()
    if seconds <= 0 then
        seconds = 5
        end_function()
    else
        hs.alert.show(seconds)
        seconds = seconds - 1
        hs.timer.doAfter(1, five_second_countdown)
    end
end

function open_discord()
    hs.application.launchOrFocus("Discord")
end

function close_discord()
    local app = hs.application.find("Discord")
    app:kill()
end

function open_discord_for_break()
    hs.timer.doAfter(20, open_discord)
    -- wait BREAK_DURATION seconds, then close discord if it's not already
    -- closed
    local BREAK_DURATION = 60 * 8 -- 8 min for now
    hs.timer.doAfter(BREAK_DURATION, end_break)
end

function end_break()
    end_function = close_discord
    hs.alert.show("Break's over!")
    five_second_countdown()
end

function log_attempt(password, attempt)
    local file_descriptor = io.open("password_attempts.csv", "a")
    file_descriptor:write(string.format("%s %s\n", password, attempt))
end

function password_then(nchars, on_success)
    local password = string.random(nchars, '%l')
    local passwordCopy = password
    local attempt = ''
    hs.alert.show(password)
    keyup_event = hs.eventtap.new({hs.eventtap.event.types.keyUp},
      function(e)
          local keycode = e:getKeyCode()
          -- 53 = esc, 36 = enter
          if (keycode == 53 or keycode == 36)  then
              keyup_event:stop()
              log_attempt(passwordCopy, attempt)
              hs.alert.show("stopping key capture")
              return true, {}
          end
          -- check if it's right
          local chars = e:getCharacters()
          if (chars ~= '7') then
              attempt = attempt .. chars
          end
          local firstchar = string.sub(password, 1, 1)
          if (chars == firstchar) then
              password = string.sub(password, 2, -1)
          end
          if (string.len(password) == 0) then
            keyup_event:stop()
            on_success()
            log_attempt(passwordCopy, attempt)
            hs.alert.show("stopping key capture")
          end
          return true, {}
      end)
    keyup_event:start()
end

hs.hotkey.bind({"cmd", "alt", "ctrl"}, '7', function()
    if not is_discordable_time() then
        hs.alert.show("You really shouldn't be on discord right now")
        password_then(12, open_discord_for_break)
        return
    end
end)
