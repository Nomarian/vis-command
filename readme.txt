
Synopsis
	Create a window with the output of command/pipe

Notes
	Once you run cmd vis:message will run, quitting will not clear the window

Use
	require(this module).Setup() or require(this module)()
	See Export if you have a conflicting command So you can register the command

Bugs
	Command uses popen which does not capture stderr, it will write to screen

Todo
	label stderr/stdout on vis:message immediately then close window?

Export
	Command -- Runs command, return output on window
	PipeCommand -- pipe range to command and returns output on window
	DIVIDER = "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
