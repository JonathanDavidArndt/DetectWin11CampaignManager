
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn   ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Load the name of the script with no extension
SplitPath, A_ScriptName, ScriptName, ScriptDir, ScriptExt, ScriptNameNoExt, ScriptDrive

; Disable/Enable services
G_EnableConsole := (!A_IsCompiled) ; Show the console during testing only

; Global Constants
G_sec  := 1000
G_min  := G_sec  * 60
G_hour := G_min  * 60
; -----------------------------------------------------------------------------



; -----------------------------------------------------------------------------
; Default configuration values
G_iniFilePath := ScriptNameNoExt . ".ini"

; Information about the Windows 11 upgrade screen, and coordinates of the "Remind me Later" button
; (can be discovered using the AutoHotKey Window Spy)
G_windowTitle := "ahk_class Campaign Manager"
G_clickX      := 240
G_clickY      := 1010

; How often to run the check (or, how long will the nag screen be visible before being automatically closed?)
G_secPollingInterval := 8

; Create the default configuration file (only if it does not already exist)
if (!FileExist(G_iniFilePath))
{
	iniPairs := "; Information about the Windows 11 upgrade screen, and coordinates of the ""Remind me Later"" button`n; (can be discovered using the AutoHotKey Window Spy)`n"
	iniPairs := iniPairs . "G_windowTitle=" . G_windowTitle . "`nG_clickX=" . G_clickX . "`nG_clickY=" . G_clickY . "`n"
	iniPairs := iniPairs . "; How often to run the check (or, how long will the nag screen be visible before being automatically closed?)`n"
	iniPairs := iniPairs . "G_secPollingInterval=" . G_secPollingInterval
	
	IniWrite, %iniPairs%, %G_iniFilePath%, Main
}
; -----------------------------------------------------------------------------



; -----------------------------------------------------------------------------
; Main program loop
CoordMode, Mouse, Client

Loop
{
	DetectWin11CampaignManager()
	Sleep, (G_sec * G_secPollingInterval)
}
ExitApp, 0
; -----------------------------------------------------------------------------



; -----------------------------------------------------------------------------
; Application specific Functions
DetectWin11CampaignManager()
{
	local
	global G_iniFilePath, G_windowTitle, G_clickX, G_clickY, G_secPollingInterval

	; Load configuration
	IniRead, G_windowTitle,        %G_iniFilePath%, Main, G_windowTitle,        %G_windowTitle%
	IniRead, G_clickX,             %G_iniFilePath%, Main, G_clickX,             %G_clickX%
	IniRead, G_clickY,             %G_iniFilePath%, Main, G_clickY,             %G_clickY%
	IniRead, G_secPollingInterval, %G_iniFilePath%, Main, G_secPollingInterval, %G_secPollingInterval%
	; Validate configuration
	G_clickX := (G_clickX < 0 ? 0 : G_clickX)
	G_clickY := (G_clickY < 0 ? 0 : G_clickY)
	G_secPollingInterval := (G_secPollingInterval < 1 ? 8 : G_secPollingInterval)

	if (0 < StrLen(G_windowTitle) && WinExist(G_windowTitle))
	{
		WinActivate ; Uses the last found window
		if (WinActive(G_windowTitle))
		{
			ClickAtCoords(G_clickX, G_clickY)
			ConsoleWrite("ClickAtCoords: " . G_windowTitle . " " . G_clickX . "x " . G_clickY . "y`n")
		}
	}
}
; -----------------------------------------------------------------------------



; -----------------------------------------------------------------------------
; General purpose functions
ClickAtCoords(x, y)
{
	local
	numClicks   := 1
	mouseSpeed  := 0 ; 0 (fastest) 100 (slowest)

	MouseGetPos, xPos, yPos ; Get original position
	MouseClick, left, x, y, numClicks, mouseSpeed
	MouseMove, xPos, yPos, mouseSpeed ; Move the mouse back when finished
}

ConsoleWrite(str)
{
    local
    global G_EnableConsole

    if (G_EnableConsole)
    {
        ; Open a console window for this demonstration
        DllCall("AllocConsole")
        ; Open the application's stdin/stdout streams in newline-translated mode
        stdout := FileOpen("*", "w")
        stdout.Write(str)
        stdout.Read(0) ; flush the buffer
        stdout.Close()
    }
}
