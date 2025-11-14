
--[[
INDEX
	VIS CRAP
	ALIASES
	MODULE
	ENV
	IMPORT
	MAIN
	EXPORT
	RETURN

Synopsis
	Creates/registers cmd and pipe
	which create a window with the output for review

Notes
	Once you run cmd vis:message will run, quitting will not clear
	so you must run an :undo on your test and quit
	or if you want it to persist, dont

Use
	require"command".Setup() or just () is usually all you need
	both functions yourself you can do so.

Bugs
	popen does not capture stdout, it will just write it it to screen

Todo
	label stderr/stdout on vis:message immediately then close window?
--]]

---------------------------------------- VIS

local vis = _G.vis

---------------------------------------- ALIASES

local Concat = table.concat
local Popen = io.popen
local Gsub = string.gsub

---------------------------------------- MODULE

local M = {}

---------------------------------------- ENV

local env, mt = {}, {
	__index = _G

	, __newindex = function ()
		error("Error: Runaway assignment on vis-command module", 2)
	end
}
local _ENV = setmetatable(env, mt)

---------------------------------------- IMPORT

-- concatenates table of strings into a bourne shell args

local BourneShellArgs = function (args_as_sequence_of_strings_T)
	local R = args_as_sequence_of_strings_T or {}
	for i,v in ipairs(R) do
		R[i] = Gsub(v, "'", "'\\''")
	end
	return "'" .. Concat(R, "' '") .. "'"
end

---------------------------------------- MAIN

local function Command(argv, force)
	local command = BourneShellArgs(argv)
	local H = Popen(command) -- BUG: popen does not capture stderr
	-- it just spits it out immediately
	local output = H:read"a"
	local status, msg, code = H:close()
	if not status then
		vis:info( ('ERROR: [%d] "%s"'):format(code, msg) )
	end
	if output and output:find"%S" then
		vis:message(output)
	end
end

-- what if selection/range is empty?
local function PipeCommand(argv, force, win, selection, range)
	local command = BourneShellArgs(argv)
	local exitN, stdout, stderr = vis:pipe(win.file, range, command)
	if exitN==0 then
		if stdout and stdout~="" then vis:message(stdout) end
		return true
	end

	local msg = {}
	if stdout and #stdout>0 then
		table.insert(msg, "STDOUT:")
		table.insert(msg, stdout)
	end
	if stderr and #stderr>0 then
		table.insert(msg, "STDERR:")
		table.insert(msg, stderr)
	end
	table.insert(msg, M.DIVIDER)

	vis:info( ("Exit status: %d"):format(exitN) )
	if #msg>0 then vis:message( table.concat(msg, "\n\n") )end
	return true
end

---------------------------------------- EXPORT

-- Sets a command called cmd that runs and opens a new window with the output
-- of the command
function M.Setup()
	vis:command_register('cmd', Command
		,'Launches <cmd> and pipes output into a new window'
	)
	vis:command_register('pipe', PipeCommand
		,'Pipes range|selection to <cmd> and return output'
	)
end

M.Command = Command
M.PipeCommand = PipeCommand

mt.__CALL = M.Setup

---------------------------------------- RETURN

return M
