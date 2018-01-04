; High Accuracy Auto-fishing for Torchlight 1 & 2
; John Jimenez johnajimenez@gmail.com
; Version 1.0
;
; Requires Autohotkey https://autohotkey.com/
; High level usage:
; 1. Position your character near the fishing hole
; 2. Mark the fishing hole with hot key
; 3. Mark the Hook/Catch button with hot key
; 4. Mark the fishing ring when it turns red (indicating fish on hook)
;  if running Torchlight 1:
;    Mark the "Ok" button on the popup that details your catch
; 5. Run the actual fishing script
;
; Keys:
; General Helpers:
; F1 : Magnifies the pixel under the cursor, this make selecting the catch ring
;      much easier
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
; Set Markers: Place mouse over element & press button. Script now uses that
;              mark for interactions
; F2 : Mark the fishing hole.
; F3 : Mark the "Catch" button (Looks like a hook. Try to stick with a portion
;      of the blue section for less misses).
; F4 : Mark the Trigger ring. The script uses this to determine when to push the
;      catch button. See notes below
; F5 : Marks the "Ok" button on the popup that details your catch
; Action:
; F6 : Starts the auto fishing.
; F7 : Stops the auto fishing.
;
; Notes:
; * The script starts with the hoykeys suspended, press F8 to enable them
; * Close fishing interface after setting markers before starting autofisher.
; * When selecting the trigger ring:
;   The script works by matching the color marked in step 4 against the colors
;   in a small area around the location marked in the same step. These tips
;   will help increase the accuracy of the matching.
;   + Using the Pixel Magnifier will GREATLY improve the accuracy of the script.
;     The magnifier also shows the rough location of what pixels will be tested
;     for a color match via the red box that follows the mouse.
;   + Pick a location that will have the least amount of color change
;     (someplace your pet can't walk, or where there is no random particle
;      movements)
; * Sometimes the start / stop fishing toggler stops accepting input, if this
;   happens, just reload the script via F12
; * There are some variables that can be tweaked to change the way the script
;   behaves. Play with them if the script is not working for you.

#SingleInstance
#MaxThreadsPerHotkey 2
#NoEnv
SendMode Event
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
CoordMode, mouse, Screen

; Testing padding around the Trigger Ring Marker. Higher number = less accuracy
triggerColorCheckBox := 4

; Time between clicking Fishing Hole and looking for a color match.
; Tweak this to help prevent false "matched" color checks.
; Slower computers may need more time, faster computers, less.
pauseForFishingInterface = 750

; Torchlight 1 Specific
; Time between clicking Catch button and Ok Button.
; Tweak this to help prevent "missed" Fishing hole clicks after a catch or to
; increase the number of attempts per hour.
; Slower computers may need more time, faster computers, less.
t1PauseBeforeOkButton = 3000

; Time between clicking Ok button and re-clicking Fishing Hole.
; Tweak this to help prevent "missed" Fishing hole clicks after a catch or to
; increase the number of attempts per hour.
; Slower computers may need more time, faster computers, less.
t1PauseBetweenFishingAttempts = 1000

; Torchlight 2 Specific
; Time between clicking Catch button and re-clicking Fishing Hole.
; Tweak this to help prevent "missed" Fishing hole clicks after a catch or to
; increase the number of attempts per hour.
; Slower computers may need more time, faster computers, less.
t2PauseBetweenFishingAttempts = 2000

; Auto Reload script when edited
SetTimer, ReloadScriptIfChanged, 4000
isFishing := False ; Flag
showDebug := False
currentAction := "Stopping Fishing"


Suspend
TimedToolTip("Auto Fishing started!`nPress F8 to enable/disable functionality!", 2000)

F1::
	toggleLiveBox := !toggleLiveBox
	if (toggleLiveBox) {
		SetTimer, showLiveSuccessBox, 150
	} else {
		SetTimer, showLiveSuccessBox, Off
		killLiveSuccessBox()
	}
return

F2::
	setFishHoleCoOrds()
	TimedToolTip("Fishing Hole Set", 1000)
return

F3::
	setCatchingCoOrds()
	TimedToolTip("Catch Hook Button Set", 1000)
return

F4::
	setCatchCheckingVars()
	TimedToolTip("Catch Ring & Color Set", 1000)
return

F5::
	setOKButtonCoOrds()
	TimedToolTip("Ok Button Set", 1000)
return

F6::
	isFishing := true
	if ( currentAction == "Stopping Fishing" ) {
		currentAction := "Initing Fishing"
		TimedToolTip("Starting to fish", 500)
		startFishing()
	}
return

F7::
	isFishing := false
	currentAction := "Stopping Fishing"
	TimedToolTip("Stopping fishing", 500)
return

F9::
	TimedToolTip("Auto Fishing variables reset", 1000)
	clearAllFishingVariables()
return

F10::
	showDebug := !showDebug
	if showDebug {
		SetTimer, debugFishingVars, 250
	} else {
		ToolTip
		SetTimer, debugFishingVars, Off
	}
return

F11::
	toggleBoxes := !toggleBoxes
	global successColor

	successBoxColor := StrReplace(successColor, "0x" , "")
	if toggleBoxes {
		CreateBox("CatchRing","FF0000")
		CreateBox("FishHole", "0000FF")
		CreateBox("CatchHook","00FF00")
		CreateBox("CatchColor", successBoxColor)
		showBoxes()
	} else {
		RemoveBox("FishHole")
		RemoveBox("CatchHook")
		RemoveBox("CatchRing")
		RemoveBox("CatchColor")
	}
return

F12::
	TimedToolTip("Reloading Auto Fishing", 1000)
	reload
return

Left::
	MouseGetPos, curX, curY
	MouseMove, (curX-1), curY
return
Right::
	MouseGetPos, curX, curY
	MouseMove, (curX+1), curY
return
Up::
	MouseGetPos, curX, curY
	MouseMove, curX, (curY-1)
return
Down::
	MouseGetPos, curX, curY
	MouseMove, curX, (curY+1)
return

F8::
	Suspend
	if (A_IsSuspended) {
		TimedToolTip("AutoFishing Keys disabled", 1500)
	} else {
		TimedToolTip("AutoFishing Keys enabled", 1500)
	}
return

Return

;; Fishing Setup, directly triggered by key presses
setFishHoleCoOrds() {
	; Put mouse over the fish hole and press trigger key

	global
	MouseGetPos fishX, fishY
}

setOKButtonCoOrds() {
	; Put mouse over the fish hole and press trigger key

	global
	MouseGetPos okButtonX, okButtonY
}


setCatchCheckingVars() {
	; Put mouse over the ring that signifies catch, and press trigger key
	; when ring turns red

	global
	MouseGetPos successX, successY
	PixelGetColor successColor, %successX%, %successY%, RGB

	colorCheckAreaX1 := (successX - (triggerColorCheckBox/2))
	colorCheckAreaY1 := (successY - (triggerColorCheckBox/2))

	colorCheckAreaX2 := (successX + (triggerColorCheckBox/2))
	colorCheckAreaY2 := (successY + (triggerColorCheckBox/2))
}

setCatchingCoOrds() {
	; Put mouse over the Hook that triggers that catch attempt and press
	; the trigger key

	global
	MouseGetPos hookX, hookY
	PixelGetColor hookColor, %hookX%, %hookY%, RGB
}

clearAllFishingVariables() {
	global

	successX =
	successY =
	fishX =
	fishY =
	colorCheckAreaX1 =
	colorCheckAreaY1 =
	colorCheckAreaX2 =
	colorCheckAreaY2 =
	successColor =
	successX =
	successY =
	hookX =
	hookY =
	okButtonX =
	okButtonY =
}

showBoxes() {
	global

	; Catch Ring Location
	if colorCheckAreaX1 {
		Box("CatchRing", colorCheckAreaX1, colorCheckAreaY1, (colorCheckAreaX2-colorCheckAreaX1), (colorCheckAreaY2-colorCheckAreaY1), 1, "out")
	}
	if colorCheckAreaX1 {
		Box("CatchColor", (colorCheckAreaX1-25), (colorCheckAreaY1 - 20), 20, 20, 10, "in")
	}

	; Fishing hole
	if fishX {
		Box("FishHole", fishX, fishY, 3, 3, 1, "out")
	}
	; Catch Hook Button
	if hookX {
		Box("CatchHook",hookX, hookY, 3, 3, 1, "out")
	}
}

debugFishingVars() {
	global

	fishDebug := "Fishing Variables`n"
	fishDebug .= "Currently Fishing: " . isFishing . "`n"
	fishDebug .= "Current Action: " . currentAction . "`n"
	fishDebug .= "Fishing Hole: " . fishX . "x " . fishY . "y`n"
	fishDebug .= "Catch Hook: " . hookX . "x " . hookY . "y`n"
	fishDebug .= "Ok Button: " . okButtonX . "x " . okButtonY . "y`n"
	fishDebug .= "Success CoOrds: " . successX . "x " . successY . "y`n"
	fishDebug .= "Check Area:`n"
	fishDebug .= "`t1: " . colorCheckAreaX1 . "x " . colorCheckAreaY1 . "y`n"
	fishDebug .= "`t2: " . colorCheckAreaX2 . "x " . colorCheckAreaY2 . "y`n"
	fishDebug .= "Trigger Color: " . successColor
	ToolTip, %fishDebug%
}

;; Fishing Actions, not triggered by key press, only used internally
clickFishHole() {
	global

	currentAction := "Clicking Fishing Hole"
	if ( isFishing ) {
		MouseMove, %fishX%, %fishY%
		Send, {LButton down}
		Sleep 100
		Send, {LButton up}
	}
}

clickHook() {
	global

	currentAction := "Clicking Catch"
	if isFishing {
		moveMouseToHook(2)
		PixelGetColor testHookColor, %hookX%, %hookY%, RGB
		if ( testHookColor == hookColor)  {
			Send, {LButton down}
			Sleep 150
			Send, {LButton up}
		} else {
			ToolTip, Not over hook
		}
	}
}

clickOkButton() {
	global

	currentAction := "Clicking Ok Button"
	if isFishing {
		ToolTip, Click "OK" Button
		MouseMove, %okButtonX%, %okButtonY%, 25
		Send, {LButton down}
		Sleep 150
		Send, {LButton up}
	}
}

moveMouseToHook(speed) {
	global
	if isFishing {
		MouseMove, (%hookX%-10), (%hookY%-10), speed
		MouseMove, (%hookX%+10), (%hookY%+10), speed
		MouseMove, %hookX%, %hookY%, speed
	}
}

startFishing() {
	global

	if ( !fishX || !hookX || !successX ) {
		TimedToolTip("Missing Data!`nMake sure you have marked Fishing Hole, Catch Hook, & Catch Ring", 2000)
		isFishing := False
		return
	}

	While isFishing {
		currentAction := "Starting to fish"
		clickFishHole()
		Sleep pauseForFishingInterface ; Allow the Fishing interface time to show up
		moveMouseToHook(15)
		checkForFish()
		moveMouseToHook(10)
		clickHook()

		if okButtonX {
			sleep t1PauseBeforeOkButton ; Give the screen time to reset
			clickOkButton()
			sleep t1PauseBetweenFishingAttempts ; Give the screen time to reset
		} else {
			sleep t2PauseBetweenFishingAttempts ; Give the screen time to reset
		}
		currentAction := "Waiting for screen to reset"
		sleep pauseBetweenFishingAttempts ; Give the screen time to reset
		ToolTip
	}
}

checkForFish() {
	global
	currentAction := "Waiting for fish"
	local pX = 0
	local pY = 0
	While isFishing {
		PixelSearch, pX, pY, colorCheckAreaX1, colorCheckAreaY1, colorCheckAreaX2, colorCheckAreaY2, successColor, 10, Fast RGB
		if !ErrorLevel {
			ToolTip, Matched!
			break
		} else {
			sleep 150 ; Let the loop pause for a beat
		}
	}
}

showLiveSuccessBox() {
	global

	MouseGetPos curX, curY
	PixelGetColor liveSuccessBoxColor, %curX%, %curY%, RGB
	; CreateBox("liveSuccessBox", "FF0000")
	CreateBox("liveSuccessBoxColor", liveSuccessBoxColor)
	; Box("liveSuccessBox", (curX - (triggerColorCheckBox/2)), (curY - (triggerColorCheckBox/2)), (triggerColorCheckBox), (triggerColorCheckBox), 1, "out")
	Box("liveSuccessBoxColor", (curX-50), (curY - 20), 30, 30, 15, "in")
}

killLiveSuccessBox() {
	; RemoveBox("liveSuccessBox")
	RemoveBox("liveSuccessBoxColor")
}

;; Some Utils
TimedToolTip(ByRef msg, dur) {
	ToolTip, %msg%
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
