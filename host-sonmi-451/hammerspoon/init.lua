--[[
Window Management:
  Inspired by: https://aaronlasseigne.com/2016/02/16/switching-from-slate-to-hammerspoon/
--]]

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "W", function()
	hs.notify.new({ title = "Hammerspoon", informativeText = "Hello World!" }):send()
end)

screens = hs.screen.allScreens()
-- Functions for keybindings
-- Bind to CTRL
function bindKey(key, fn)
	hs.hotkey.bind({ "ctrl" }, key, fn)
end

--Bind to HYPER
function bindHyperKey(key, fn)
	hs.hotkey.bind({ "ctrl", "alt,", "command", "shift" }, key, fn)
end

-- Define positions
positions = {
	maximize = hs.layout.maximized,
	center = hs.geometry.new({ x = 0.125, y = 0.0, w = 0.75, h = 1.0 }),
	absolute_center = hs.geometry.new({ x = 0.125, y = 0.125, w = 0.75, h = 0.75 }),
	center_left_for_stage_manager = { x = 0.10, y = 0, w = 0.65, h = 1 },

	middle_left = hs.geometry.new({ x = 0.125, y = 0.125, w = 0.33, h = 0.75 }),
	middle_right = hs.geometry.new({ x = 0.455, y = 0.125, w = 0.33, h = 0.75 }),

	left_half = hs.layout.left50,
	left_2thirds = { x = 0, y = 0, w = 0.66, h = 1 },
	left_2thirds_half = { x = 0, y = 0, w = 0.66, h = 0.5 },

	right_half = hs.layout.right50,
	right_90 = { x = 0.10, y = 0, w = 0.9, h = 1 },
	right_2thirds = { x = 0.34, y = 0, w = 0.66, h = 1 },
	right_2thirds_half = { x = 0.34, y = 0, w = 0.66, h = 0.5 },

	left_third = { x = 0, y = 0, w = 0.34, h = 1.0 },
	middle_third = { x = 0.34, y = 0, w = 0.34, h = 1.0 },
	right_third = { x = 0.66, y = 0, w = 0.34, h = 1.0 },

	right_quarter_third = { x = 0.50, y = 0, w = 0.25, h = 1.0 },
	right_quarter_edge = { x = 0.75, y = 0, w = 0.25, h = 1.0 },

	-- Not used
	bot_13 = { x = 0, y = 0.5, w = 0.33, h = 0.5 },
	bot_23 = { x = 0.33, y = 0.5, w = 0.33, h = 0.5 },
	bot_33 = { x = 0.66, y = 0.5, w = 0.34, h = 0.5 },
	upperhalf = { x = 0, y = 0, w = 1, h = 0.5 },
	lowerhalf = { x = 0, y = 0.5, w = 1, h = 0.5 },
	top_12 = { x = 0, y = 0, w = 0.5, h = 0.5 },
	top_22 = { x = 0.5, y = 0, w = 0.5, h = 0.5 },
	bot_12 = { x = 0, y = 0.5, w = 0.5, h = 0.5 },
	bot_22 = { x = 0.5, y = 0.5, w = 0.5, h = 0.5 },
}

-- Set up keybinding table
mainPositionKeys = {
	{ key = "q", units = positions.left_2thirds },
	{ key = "]", units = positions.right_2thirds },
	{ key = "m", units = positions.middle_right },
	{ key = "n", units = positions.middle_left },
	{ key = "g", units = positions.center },
	{ key = "\\", units = positions.right_90 },
	{ key = "'", units = positions.center_left_for_stage_manager },
}
secondaryPositionKeys = {
	{ key = "f", units = positions.maximize },
	{ key = "q", units = positions.left_half },
	{ key = "]", units = positions.right_half },
	{ key = "1", units = positions.left_third },
	{ key = "2", units = positions.middle_third },
	{ key = "3", units = positions.right_third },
	{ key = "4", units = positions.right_quarter_third },
	{ key = "5", units = positions.right_quarter_edge },
	{ key = "g", units = positions.absolute_center },
}

-- Go through window position and define keybindings
hs.fnutils.each(mainPositionKeys, function(entry)
	bindKey(entry.key, function()
		hs.window.focusedWindow():moveToUnit(entry.units)
	end)
end)

hs.fnutils.each(secondaryPositionKeys, function(entry)
	bindHyperKey(entry.key, function()
		hs.window.focusedWindow():moveToUnit(entry.units)
	end)
end)

function moveScreen(focus)
	local screen = hs.screen.mainScreen()

	if screen:currentMode().w > 1920 then
		focus:moveOneScreenEast()
		focus:moveToUnit(positions.maximize)
	elseif screen:name() == "DELL U2412M" then
		focus:moveOneScreenWest()
		focus:moveToUnit(positions.left_half)
	elseif screen:name() == "T24v-20" then
		focus:moveOneScreenWest()
		focus:moveToUnit(positions.maximize)
	elseif screen:name() == "LEN T24i-20" then
		focus:moveOneScreenEast()
		focus:moveToUnit(positions.maximize)
	end
end

--[[
SSH Lock Function:
  Watches for computer to go to sleep, power off, or have screen lock and locks
  ssh keys on those events. The lock keys script clears ssh-add and
  removes any autocontrol sockets from ~/.ssh/sockets.

  Taken from: http://fanf.livejournal.com/139925.html
--]]
local pow = hs.caffeinate.watcher
local log = hs.logger.new("ssh-lock")

local function ok2str(ok)
	if ok then
		return "ok"
	else
		return "fail"
	end
end

local function on_pow(event)
	local name = "?"
	for key, val in pairs(pow) do
		if event == val then
			name = key
		end
	end
	log.f("caffeinate event %d => %s", event, name)
	if
		event == pow.screensDidSleep
		or event == pow.systemWillSleep
		or event == pow.systemWillPowerOff
		or event == pow.sessionDidResignActive
		or event == pow.screensDidLock
	then
		log.i("sleeping...")
		local ok, st, n = os.execute("${HOME}/.functions/maintenance/lock_keys.zsh")
		log.f("lock_keys => %s %s %d", ok2str(ok), st, n)
		return
	end
end

pow.new(on_pow):start()

log.i("started")

-- Get's an array length, useful in some functions above
function getLength(array)
	length = 0
	for i in pairs(array) do
		length = length + 1
	end
	return length
end

-- Convert Month name to integer
function getMonth(string)
	monthIndex = 0
	monthArray = {
		"January",
		"February",
		"March",
		"April",
		"May",
		"June",
		"July",
		"August",
		"September",
		"October",
		"November",
		"December",
	}
	length = getLength(monthArray)
	for i = 1, length do
		if monthArray[i] == string then
			monthIndex = i
		end
	end
	return monthIndex
end

-- Swap keys and values
function invertTable(inputTable)
	invertedTable = {}
	for index, value in pairs(inputTable) do
		invertedTable[value] = index
	end
	return invertedTable
end

--Sort the keys of a table by making a new table of said keys
function sortKeys(inputTable)
	sorted = {}
	for n, k in pairs(inputTable) do
		table.insert(sorted, n)
	end
	table.sort(sorted, function(a, b)
		return a > b
	end)
	return sorted
end
