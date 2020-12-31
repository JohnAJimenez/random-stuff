; Auto-fishing for Minecraft
; John Jimenez johnajimenez@gmail.com
; Version 1.0
;
; Environment at the time of writing:
; Auto Hot Key 1.1.33.02 https://autohotkey.com/
; Minecraft Bedrock on Windows 10 1.16.201 https://www.minecraft.net/
; Fishing farm by JC Playz https://www.youtube.com/watch?v=yvsvFrILXJY
;
; In theory, this will work for any fishing farm that automatically reels in.
; The code for recasting is looking to match a designated color at a designated
; pixel.
;
; High level usage:
; 1. Position yourself at the fishing farm
; 2. Mark the fishing hook (used for color comparision)
; 3. Unsuspend the hotkeys
; 4. Start the autofishing
;
; Keys:
; General Helpers:
; F8 : Toggles suspending of the hotkeys
; F9 : Clear all previously set markers
; F10 : Show the debugging variables via tooltip (tends to get in the way of
;       script running properly)
; F11 : Toggle the marker indicators. Places boxes on the screen around the
;       different markers that have been set
; F12 : Fully reload the script
; Arrow Keys: Moves the mouse by individual pixels to help pick the trigger
;             ring
;
; F2 : Mark the fishing hook.
; Action:
; F3 : Starts the auto fishing.
; F4 : Stops the auto fishing.
;
; Setup:
; 1. Make sure the game is in windowed mode (not full screen) on the primary
;    monitor (color matching does not work otherwise)
; 2. Go to the fishing location and set your set up to fish as per the video
; 3. Ensure that your fishing rod is NOT cast out
; 4. Press Esc key to unlock your mouse
; 5. Place your mouse over the hook on your fishing rod
; 6. Unpause the game
; 7. Press F8 to enable the script's hotkeys
; 8. Press F2 to record the color of the hook
; 9. Cast the fishing rod and ensure that your fishing farm is working
;    (meaning that your hook returns automatically when you catch something)
; 10. Press F3 to turn on the auto fishing
; 11. Go enjoy your life
; 12. Press F4 to stop the auto fishing
; 13. Press F8 to disable the script's hotkeys
; 14. Exit the script when done
;
; Notes:
; * The script starts with the hoykeys suspended, press F8 to enable them
; * Ensure that you have a torch near you to reduce color changes on hook.

#SingleInstance
#MaxThreadsPerHotkey 2
#NoEnv
SendMode Event
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
CoordMode, mouse, Screen

; Testing padding around the Trigger Ring Marker. Higher number = less accuracy
triggerColorCheckBox := 4

; Auto Reload script when edited
SetTimer, ReloadScriptIfChanged, 4000
isFishing := False ; Flag
showDebug := False
currentAction := "Not Fishing"


Suspend
CorneredTimedToolTip("Auto Fishing started!`nPress F8 to enable/disable functionality!", 2000)

F2::
	setCatchCheckingVars()
	CorneredTimedToolTip("Fishing hook location & color set", 1000)
return

F3::
	isFishing := true
	if ( currentAction == "Not Fishing" ) {
		currentAction := "Initing Fishing"
		CorneredTimedToolTip("Start Fishing", 500)
		startFishing()
	}
return

F4::
	isFishing := false
	currentAction := "Not Fishing"
	CorneredTimedToolTip("Stop Fishing", 500)
return

F8::
	Suspend
	if (A_IsSuspended) {
		CorneredTimedToolTip("AutoFishing Keys disabled", 1500)
	} else {
		CorneredTimedToolTip("AutoFishing Keys enabled", 1500)
	}
return

F9::
	CorneredTimedToolTip("Auto Fishing variables reset", 1000)
	clearAllFishingVariables()
return

F10::
	showDebug := !showDebug
	if showDebug {
		SetTimer, debugFishingVars, 250
	}
return

F11::
	toggleBoxes := !toggleBoxes
	global successColor

	successBoxColor := StrReplace(successColor, "0x" , "")
	if toggleBoxes {
		CreateBox("CatchRing","FF0000")
		CreateBox("CatchColor", successBoxColor)
		showBoxes()
	} else {
		RemoveBox("CatchRing")
		RemoveBox("CatchColor")
	}
return

F12::
	CorneredTimedToolTip("Reloading Auto Fishing", 1000)
	reload
return


Return


setCatchCheckingVars() {
	; Put mouse over the the fishing hook and press hotkey to save testing spot
	; and color

	global
	MouseGetPos successX, successY
	PixelGetColor successColor, %successX%, %successY%, Slow

	colorCheckAreaX1 := (successX - (triggerColorCheckBox/2))
	colorCheckAreaY1 := (successY - (triggerColorCheckBox/2))

	colorCheckAreaX2 := (successX + (triggerColorCheckBox/2))
	colorCheckAreaY2 := (successY + (triggerColorCheckBox/2))
}


clearAllFishingVariables() {
	global

	successX =
	successY =
	colorCheckAreaX1 =
	colorCheckAreaY1 =
	colorCheckAreaX2 =
	colorCheckAreaY2 =
	successColor =
}

showBoxes() {
	global

	; Catch Ring Location
	if colorCheckAreaX1 {
		Box("CatchRing", colorCheckAreaX1, colorCheckAreaY1, (colorCheckAreaX2-colorCheckAreaX1), (colorCheckAreaY2-colorCheckAreaY1), 1, "out")
		Box("CatchColor", (colorCheckAreaX1-25), (colorCheckAreaY1 - 20), 20, 20, 10, "in")
	}
}

debugFishingVars() {
	global

	MouseGetPos debugCurX, debugCurY
	PixelGetColor debugCursorPixelColor, %debugCurX%, %debugCurY%, Slow

	if ( showDebug ){
		fishDebug := "Fishing Variables`n"
		fishDebug .= "Currently Fishing: " . isFishing . "`n"
		fishDebug .= "Current Action: " . currentAction . "`n"
		fishDebug .= "Success CoOrds: " . successX . "x " . successY . "y`n"
		fishDebug .= "Check Area:`n"
		fishDebug .= "`t1: " . colorCheckAreaX1 . "x " . colorCheckAreaY1 . "y`n"
		fishDebug .= "`t2: " . colorCheckAreaX2 . "x " . colorCheckAreaY2 . "y`n"
		fishDebug .= "Trigger Color: " . successColor . "`n"
		fishDebug .= "Current Pixel Color: " . debugCursorPixelColor
		ToolTip, %fishDebug%, 0, 0, 19
	}
	else {
		ToolTip,, 0, 0, 19
		SetTimer, debugFishingVars, Off
	}

}

castRod() {
	global

	if isFishing {
		currentAction := "Casting Rod"
		Send, {RButton down}
		Sleep 75
		Send, {RButton up}
	}
}

startFishing() {
	global

	if ( !successX ) {
		CorneredTimedToolTip("Missing Data!`nYou need to mark the fishing hook", 2000)
		isFishing := False
		return
	}

	While isFishing {
		currentAction := "Fishing"
		Sleep 250
		waitForHookReturn()
		Sleep 250
		castRod()
	}
}

waitForHookReturn() {
	global
	currentAction := "Waiting for hook to return"
	local pX = 0
	local pY = 0
	While isFishing {
		PixelSearch, pX, pY, colorCheckAreaX1, colorCheckAreaY1, colorCheckAreaX2, colorCheckAreaY2, successColor, 15, Fast RGB
		if !ErrorLevel {
			break
		} else {
			sleep 150 ; Let the loop pause for a beat
		}
	}
}

;; Some Utils
CorneredTimedToolTip(ByRef msg, dur) {
	ToolTip, %msg%, 1, 1
	SetTimer, RemoveToolTip, %dur%
}

RemoveToolTip:
	SetTimer, RemoveToolTip, Off
	ToolTip
return


ReloadScriptIfChanged:
{
	FileGetAttrib, FileAttribs, %A_ScriptFullPath%
	IfInString, FileAttribs, A
	{
		FileSetAttrib, -A, %A_ScriptFullPath%
		TrayTip, Reloading Script..., %A_ScriptName%, , 1
		Sleep, 1000
		Reload
		TrayTip
	}
	Return
}


;;;;;;;;;
;; Box code stolen from https://autohotkey.com/board/topic/54443-box-ie-draw-simple-gui-based-boxes-on-screen/
;;
CreateBox(Name, Color)
{
	Gui %Name%81:color, %Color%
	Gui %Name%81:+ToolWindow -SysMenu -Caption +AlwaysOnTop
	Gui %Name%82:color, %Color%
	Gui %Name%82:+ToolWindow -SysMenu -Caption +AlwaysOnTop
	Gui %Name%83:color, %Color%
	Gui %Name%83:+ToolWindow -SysMenu -Caption +AlwaysOnTop
	Gui %Name%84:color, %Color%
	Gui %Name%84:+ToolWindow -SysMenu -Caption +AlwaysOnTop
}

Box(Name, XCor, YCor, Width, Height, Thickness, Offset)
{
	If InStr(Offset, "In")
	{
		StringTrimLeft, offset, offset, 2
		If not Offset
			Offset = 0
		Side = -1
	} Else {
		StringTrimLeft, offset, offset, 3
		If not Offset
			Offset = 0
		Side = 1
	}
	x := XCor - (Side + 1) / 2 * Thickness - Side * Offset
	y := YCor - (Side + 1) / 2 * Thickness - Side * Offset
	h := Height + Side * Thickness + Side * Offset * 2
	w := Thickness
	Gui %Name%81:Show, x%x% y%y% w%w% h%h% NA
	x += Thickness
	w := Width + Side * Thickness + Side * Offset * 2
	h := Thickness
	Gui %Name%82:Show, x%x% y%y% w%w% h%h% NA
	x := x + w - Thickness
	y += Thickness
	h := Height + Side * Thickness + Side * Offset * 2
	w := Thickness
	Gui %Name%83:Show, x%x% y%y% w%w% h%h% NA
	x := XCor - (Side + 1) / 2 * Thickness - Side * Offset
	y += h - Thickness
	w := Width + Side * Thickness + Side * Offset * 2
	h := Thickness
	Gui %Name%84:Show, x%x% y%y% w%w% h%h% NA
}

RemoveBox(Name)
{
	Gui %Name%81:destroy
	Gui %Name%82:destroy
	Gui %Name%83:destroy
	Gui %Name%84:destroy
}
