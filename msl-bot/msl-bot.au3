#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\..\favicon.ico
#AutoIt3Wrapper_Outfile=msl-bot v1.10.exe
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Description=An open-sourced Monster Super League bot
#AutoIt3Wrapper_Res_Fileversion=1.10.2.0
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

;Initialize Bot
Global $botConfig = "config.ini"
Global $botVersion = "v1.10.2.0"
Global $botName = "MSL Bot"
Global $arrayScripts = StringSplit(IniRead(@ScriptDir & "/" & $botConfig, "general", "scripts", ""), ",", 2)

;defining globals
Global $botTitle = IniRead(@ScriptDir & "/" & $botConfig, "general", "emulator-title", "BlueStacks App Player")
Global $botInstance = IniRead(@ScriptDir & "/" & $botConfig, "general", "emulator-instance", "[CLASS:BlueStacksApp; INSTANCE:1]")

Global $hWindow = WinGetHandle($botTitle)
Global $hControl = ControlGetHandle($botTitle, "", $botInstance)

Global $diff = ControlGetPos($botTitle, "", $hControl) ;

Global $strScript = "" ;script section
Global $strConfig = "" ;all keys

Global $iniBackground = IniRead(@ScriptDir & "/" & $botConfig, "general", "background-mode", 1) ;checkbox, declare first to remove warning
Global $iniRealMouse = IniRead(@ScriptDir & "/" & $botConfig, "general", "real-mouse-mode", 1) ;^
Global $iniOutput = IniRead(@ScriptDir & "/" & $botConfig, "general", "output-all-process", 1) ;^

#include "core/imports.au3"
#include "core/gui.au3"

_GDIPlus_Startup()
GUICtrlSetData($lblVersion, "Current version: " & $botVersion)
GUICtrlSetData($cmbLoad, StringReplace(IniRead(@ScriptDir & "/" & $botConfig, "general", "scripts", "There are no scripts available."), ",", "|"))

Dim $arrayKeys = StringSplit(IniRead(@ScriptDir & "/" & $botConfig, "general", "keys", ""), ",", 2)
Dim $generalConfig = ""
For $key In $arrayKeys
	$generalConfig &= $key & "=" & IniRead(@ScriptDir & "/" & $botConfig, "general", $key, "???") & "|"
Next
GUICtrlSetData($listConfig, $generalConfig)

loadLocation() ;loads up location from /core/location.txt

;importing scripts
#include "script/imports.au3"

;Hotkeys =====================================
HotKeySet("{END}", "hotkeyStopBot")
HotKeySet("{F6}", "debugPoint1")
HotKeySet("{F7}", "debugPoint2")

Func debugPoint1()
	getEmulatorHandle()

	$pointDebug1[0] = MouseGetPos(0) - WinGetPos($hControl)[0]
	$pointDebug1[1] = MouseGetPos(1) - WinGetPos($hControl)[1]

	;_CaptureRegion()
	;ClipPut($pointDebug1[0] & "," & $pointDebug1[1] & ",0x" & Hex(_GDIPlus_BitmapGetPixel($hBitmap, $pointDebug1[0], $pointDebug1[1]), 6))

	If $pointDebug1[0] > 800 Or $pointDebug1[0] < 0 Or $pointDebug1[1] > 600 Or $pointDebug1[1] < 0 Then
		$pointDebug1[0] = "?"
		$pointDebug1[1] = "?"
	EndIf

	GUICtrlSetData($lblDebugCoordinations, "F6: (" & $pointDebug1[0] & ", " & $pointDebug1[1] & ") | F7: (" & $pointDebug2[0] & ", " & $pointDebug2[1] & ")")
EndFunc   ;==>debugPoint1

Func debugPoint2()
	getEmulatorHandle()

	$pointDebug2[0] = MouseGetPos(0) - WinGetPos($hControl)[0]
	$pointDebug2[1] = MouseGetPos(1) - WinGetPos($hControl)[1]
	If $pointDebug2[0] > 800 Or $pointDebug2[0] < 0 Or $pointDebug2[1] > 600 Or $pointDebug2[1] < 0 Then
		$pointDebug2[0] = "?"
		$pointDebug2[1] = "?"
	EndIf

	GUICtrlSetData($lblDebugCoordinations, "F6: (" & $pointDebug1[0] & ", " & $pointDebug1[1] & ") | F7: (" & $pointDebug2[0] & ", " & $pointDebug2[1] & ")")
EndFunc   ;==>debugPoint2

Func hotkeyStopBot()
	$boolRunning = False
	GUICtrlSetData($btnRun, "Start")
EndFunc   ;==>hotkeyStopBot

;main loop
While True
	If $boolRunning = True Then
		If $hControl = 0 Then
			$boolRunning = False
			GUICtrlSetData($btnRun, "Start")
			setLog("Error: Could not find instance.", 2)

			ContinueLoop
		EndIf

		If Not $strScript = "" Then ;check if script is set
			Call(IniRead(@ScriptDir & "/" & $botConfig, $strScript, "function", ""))
			If @error = 0xDEAD And @extended = 0xBEEF Then MsgBox($MB_OK, $botName & " " & $botVersion, "Script function does not exist.")
			$boolRunning = False
			GUICtrlSetData($btnRun, "Start")
		Else
			MsgBox($MB_OK, $botName & " " & $botVersion, "Load a script before starting.")
			$boolRunning = False
			GUICtrlSetData($btnRun, "Start")
		EndIf
	EndIf
	Sleep(10)
WEnd

;function: btnRunClick
Func btnRunClick()
	getEmulatorHandle()

	If $boolRunning = False Then ;starting bot
		If $iniRealMouse = 1 Then MsgBox($MB_ICONINFORMATION, $botName & " " & $botVersion, "You have real mouse on! You will not be able to use your mouse. To stop script press End key.")
		$boolRunning = True

		GUICtrlSetData($btnRun, "Stop")
	Else ;ending bot
		$boolRunning = False

		GUICtrlSetData($btnRun, "Start")
	EndIf
EndFunc   ;==>btnRunClick

;function: frmMainClose
;-Exits application and saves the log
;author: GkevinOD (2017)
Func frmMainClose()
	Dim $strOutput = GUICtrlRead($textOutput)
	If Not $strOutput = "" Then FileWrite(@ScriptDir & "/core/data/logs/" & StringReplace(_NowDate(), "/", "."), $strOutput)
	_GDIPlus_Shutdown()
	Exit 0
EndFunc   ;==>frmMainClose

;function: btnSetConfig
;-Sets which config is used.
;author: GkevinOD (2017)
Func btnSetConfig()
	If FileExists(@ScriptDir & "/" & GUICtrlRead($textConfig)) Then
		$botConfig = GUICtrlRead($textConfig)

		Dim $arrayKeys = StringSplit(IniRead(@ScriptDir & "/" & $botConfig, "general", "keys", ""), ",", 2)
		Dim $generalConfig = ""
		For $key In $arrayKeys
			$generalConfig &= $key & "=" & IniRead(@ScriptDir & "/" & $botConfig, "general", $key, "???") & "|"
		Next

		$iniBackground = IniRead(@ScriptDir & "/" & $botConfig, "general", "background-mode", 1) ;checkbox, declare first to remove warning
		$iniRealMouse = IniRead(@ScriptDir & "/" & $botConfig, "general", "real-mouse-mode", 1) ;^
		$iniOutput = IniRead(@ScriptDir & "/" & $botConfig, "general", "output-all-process", 1) ;^

		GUICtrlSetData($listConfig, "")
		GUICtrlSetData($listConfig, $generalConfig)

		cmbLoadClick()

		Global $botTitle = IniRead(@ScriptDir & "/" & $botConfig, "general", "emulator-title", "BlueStacks App Player")
		Global $botInstance = IniRead(@ScriptDir & "/" & $botConfig, "general", "emulator-instance", "[CLASS:BlueStacksApp; INSTANCE:1]")

		Global $hWindow = WinGetHandle($botTitle)
		Global $hControl = ControlGetHandle($botTitle, "", $botInstance)

		Global $diff = ControlGetPos($botTitle, "", $hControl) ;

		Global $strScript = "" ;script section
		Global $strConfig = "" ;all keys

		Global $iniBackground = IniRead(@ScriptDir & "/" & $botConfig, "general", "background-mode", 1) ;checkbox, declare first to remove warning
		Global $iniRealMouse = IniRead(@ScriptDir & "/" & $botConfig, "general", "real-mouse-mode", 1) ;^
		Global $iniOutput = IniRead(@ScriptDir & "/" & $botConfig, "general", "output-all-process", 1) ;^
	EndIf
EndFunc   ;==>btnSetConfig

;function: lblDiscordClick
;-Label hyperlink
;author: GkevinOD (2017)
Func lblDiscordClick()
	ShellExecute("https://discord.gg/UQGRnwf")
EndFunc   ;==>lblDiscordClick

;function: lblDonateClick
;-Label hyperlink
;author: GkevinOD (2017)
Func lblDonateClick()
	ShellExecute("https://www.paypal.me/gkevinod")
EndFunc   ;==>lblDonateClick

;function: btnClearClick()
;-Clears the output and saves it to a file.
;author: GkevinOD (2017)
Func btnClearClick()
	Dim $strOutput = GUICtrlRead($textOutput)
	If Not $strOutput = "" Then FileWrite(@ScriptDir & "/core/data/logs/" & StringReplace(_NowDate(), "/", "."), $strOutput)
	GUICtrlSetData($textOutput, "")
EndFunc   ;==>btnClearClick

;function: btnDebugTestCodeClick
;-Runs a line of code and performs it.
;pre:
;	-must be a call to function
;	-no script must be running
;author: GkevinOD (2017)
Func btnDebugTestCodeClick()
	;running line of code using execute
	$boolRunning = True
	Execute(GUICtrlRead($textDebugTestCode))
	$boolRunning = False
EndFunc   ;==>btnDebugTestCodeClick

;functon: btnConfigEdit
;-Modify a config of the general config
;pre:
;	-no script must be running
;author: GkevinOD (2017)
Func btnConfigEdit()
	;initial variables
	Dim $strRaw = GUICtrlRead($listConfig)
	Dim $arrayRaw = StringSplit($strRaw, "=", 2)

	If UBound($arrayRaw) = 1 Then ;check if no config selected
		MsgBox(0, $botName & " " & $botVersion, "No config selected.")
		Return
	EndIf

	;getting keys and values to modify
	Dim $key = $arrayRaw[0]
	Dim $value = "!" ;temp value
	Dim $boolPass = False ;if meets restriction

	Dim $rawRestrictions = IniRead(@ScriptDir & "/" & $botConfig, "general", $key & "-restrictions", "")
	If Not $rawRestrictions = "" Then
		Dim $restrictions = StringSplit($rawRestrictions, ",", 2)

		While $value = "!"
			$value = InputBox($botName & " " & $botVersion, "Enter new value for '" & $key & "'" & @CRLF & "You are limited to: " & StringReplace($rawRestrictions, ",", ", "))
			If $value = "" Then $value = $arrayRaw[1]

			For $element In $restrictions
				If $element = $value Then ExitLoop (2)
			Next
			$value = "!"
		WEnd
	Else
		$value = InputBox($botName & " " & $botVersion, "Enter new value for '" & $key & "'")
		If $value = "" Then $value = $arrayRaw[1]
	EndIf

	;overwrite file
	IniWrite(@ScriptDir & "/" & $botConfig, "general", $key, $value) ;write to config file

	Dim $arrayKeys = StringSplit(IniRead(@ScriptDir & "/" & $botConfig, "general", "keys", ""), ",", 2)
	Dim $generalConfig = ""
	For $key In $arrayKeys
		$generalConfig &= $key & "=" & IniRead(@ScriptDir & "/" & $botConfig, "general", $key, "???") & "|"
	Next

	$iniBackground = IniRead(@ScriptDir & "/" & $botConfig, "general", "background-mode", 1) ;checkbox, declare first to remove warning
	$iniRealMouse = IniRead(@ScriptDir & "/" & $botConfig, "general", "real-mouse-mode", 1) ;^
	$iniOutput = IniRead(@ScriptDir & "/" & $botConfig, "general", "output-all-process", 1) ;^

	GUICtrlSetData($listConfig, "")
	GUICtrlSetData($listConfig, $generalConfig)

	btnSetConfig()
EndFunc   ;==>btnConfigEdit

;function: cmbLoadClick
;-Load a script from the list of scripts written in the config
;pre:
;	-configs must be set
;	-no script must be running
;author: GkevinOD (2017)
Func cmbLoadClick()
	;pre
	If GUICtrlRead($cmbLoad) = "Select a script.." Then
		GUICtrlSetData($listScript, "") ;reset list
		Return
	EndIf

	;clearing data
	GUICtrlSetData($listScript, "")

	;process of getting info
	$strScript = GUICtrlRead($cmbLoad)
	If $strScript = "null" Then $strScript = ""

	Dim $arrayKeys = StringSplit(IniRead(@ScriptDir & "/" & $botConfig, $strScript, "keys", ""), ",", 2)
	$strConfig = ""
	For $key In $arrayKeys
		$strConfig &= $key & "=" & IniRead(@ScriptDir & "/" & $botConfig, $strScript, $key, "???") & "|"
	Next

	;final
	GUICtrlSetData($listScript, $strConfig)
EndFunc   ;==>cmbLoadClick

;functon: btnEditClick
;-Modify a config of the selected config from the $listScript
;pre:
;	-something selected for $listScript
;	-no script must be running
;author: GkevinOD (2017)
Func btnEditClick()
	;initial variables
	Dim $strRaw = GUICtrlRead($listScript)
	Dim $arrayRaw = StringSplit($strRaw, "=", 2)

	If UBound($arrayRaw) = 1 Then ;check if no config selected
		MsgBox(0, $botName & " " & $botVersion, "No config selected.")
		Return
	EndIf

	;getting keys and values to modify
	Dim $key = $arrayRaw[0]
	Dim $value = "!" ;temp value
	Dim $boolPass = False ;if meets restriction

	Dim $rawRestrictions = IniRead(@ScriptDir & "/" & $botConfig, $strScript, $key & "-restrictions", "")
	If Not $rawRestrictions = "" Then
		Dim $restrictions = StringSplit($rawRestrictions, ",", 2)

		While $value = "!"
			$value = InputBox($botName & " " & $botVersion, "Enter new value for '" & $key & "'" & @CRLF & "You are limited to: " & StringReplace($rawRestrictions, ",", ", "))
			If $value = "" Then $value = $arrayRaw[1]

			For $element In $restrictions
				If $element = $value Then ExitLoop (2)
			Next
			$value = "!"
		WEnd
	Else
		$value = InputBox($botName & " " & $botVersion, "Enter new value for '" & $key & "'")
		If $value = "" Then $value = $arrayRaw[1]
	EndIf

	;overwrite file
	IniWrite(@ScriptDir & "/" & $botConfig, $strScript, $key, $value) ;write to config file

	cmbLoadClick()
EndFunc   ;==>btnEditClick

;function: chkDebugFindImageClick()
;-Intervals of 1/2 seconds, tries to find image within bluestacks window
;pre:
;	-must not have script running
;	-image file exist
;post:
;	-edit the lblDebugFindImage to result
;author: GkevinOD (2017)
Func chkDebugFindImageClick()
	getEmulatorHandle()

	If $hControl = 0 Then
		setLog("Error: Could not find instance.", 2)
		GUICtrlSetState($chkDebugFindImage, 0)
		Return
	EndIf

	$boolRunning = True
	While (GUICtrlRead($chkDebugFindImage) = 1) ;if it is checked
		Dim $strImage = GUICtrlRead($textDebugImage)
		Dim $dirImage = ""
		;first check if file exist
		If StringInStr($strImage, "-") Then ;image with specified folder
			$dirImage = StringSplit($strImage, "-", 2)[0] & "\" & $strImage
		EndIf

		;process
		If Not FileExists($strImageDir & $dirImage & ".bmp") Then
			GUICtrlSetData($lblDebugImage, "Found: Non-Existent" & @CRLF & "Size: 0")
		Else
			Local $arrayPoints = findImage($strImage, 30)
			If Not IsArray($arrayPoints) Then ;if not found
				GUICtrlSetData($lblDebugImage, "Found: 0" & @CRLF & "Size: 0")
			Else
				Local $hImage = _GDIPlus_ImageLoadFromFile($strImageDir & $dirImage & ".bmp")
				GUICtrlSetData($lblDebugImage, "Found: " & $arrayPoints[0] & ", " & $arrayPoints[1] & @CRLF & "Size: " & _GDIPlus_ImageGetWidth($hImage) & ", " & _GDIPlus_ImageGetHeight($hImage))
			EndIf
		EndIf

		Sleep(500) ;
	WEnd
	$boolRunning = False
EndFunc   ;==>chkDebugFindImageClick

;function: btnSetClick()
;-If in debug, location is 'unknown' this button can set the location of the unknown.
;pre:
;	-location must be unknown.
; 	-location input must exist.
;post:
;	-create an image to be the new location or alternative location
;author: GkevinOD (2017)
Func btnSetClick()
	If Not getLocation() = "unknown" Then
		setLog("Warning: This location is already set to: " & getLocation() & "!", 2)
		setLog("Your new location will be prioritized.", 2)
	EndIf

	Local $limit = "" ;

	For $location In $listLocation
		$limit &= $location[0] & ", "
	Next
	$limit = StringTrimRight($limit, 2)

	Local $strLocation = "unknown"
	While $strLocation = "unknown"
		$strLocation = InputBox($botName & " " & $botVersion, "Enter CURRENT location:" & @CRLF & @CRLF & "You are limited to: " & $limit, Default, Default, 500, 230)
		If $strLocation = "" Then Return

		For $element In StringSplit($limit, ", ", 2)
			If $element = $strLocation Then ExitLoop (2)
		Next
		$strLocation = "unknown"
	WEnd

	If IsArray($listLocation) = False Then loadLocation()
	For $location In $listLocation
		If $strLocation = $location[0] Then
			Local $newLoc = $strLocation & ":"
			For $pixelSet In StringSplit($location[1], "/", 2)
				For $pixel In StringSplit($pixelSet, "|", 2)
					Local $pixelPart = StringSplit($pixel, ",", 2)
					$newLoc &= $pixelPart[0] & "," & $pixelPart[1] & ","
					$newLoc &= "0x" & Hex(_GDIPlus_BitmapGetPixel($hBitmap, $pixelPart[0], $pixelPart[1]), 6)
					$newLoc &= "|"
				Next
				$newLoc &= "/"
			Next
			$newLoc = StringTrimRight($newLoc, 2)
			ExitLoop
		EndIf
	Next
	FileWrite(@ScriptDir & "/core/locations-extra.txt", @CRLF & $newLoc)
	loadLocation()

	setLog("New location has been added to locations-extra.txt!", 2)
	setLog("Test using the debug 'Location'.", 2)
	setLog("If you made a mistake, delete that locations in /core/locations-extra.txt")
EndFunc   ;==>btnSetClick

;function: chkDebugLocationClick()
;-Intervals of 1/2 seconds, tries to find the location of the game
;pre:
;	-must not have script running
;	-image file exist
;post:
;	-edit the lblDebugLocation to result
;author: GkevinOD (2017)
Func chkDebugLocationClick()
	getEmulatorHandle()

	If $hControl = 0 Then
		setLog("Error: Could not find instance.", 2)
		GUICtrlSetState($chkDebugLocation, 0)
		Return
	EndIf

	While (GUICtrlRead($chkDebugLocation) = 1) ;if it is checked
		GUICtrlSetData($chkDebugLocation, "Location: " & getLocation())
		Sleep(500) ;
	WEnd
EndFunc   ;==>chkDebugLocationClick

;function: btnSaveImage()
;-Save Image using the points given
;post:
;	-create an image using points
;author: GkevinOD (2017)
Func btnSaveImage()
	Local $strImage = "unknown"
	While $strImage = "unknown"
		Local $strAvailableFolders = "battle,catch,gem,location,monster,map,misc"
		$strImage = InputBox($botName & " " & $botVersion, "Enter image name:" & @CRLF & @CRLF & "The folder is limited to (FOLDER-IMAGENAME): " & StringReplace($strAvailableFolders, ",", ", "))
		If $strImage = "" Then Return

		For $element In StringSplit($strAvailableFolders, ",", 2)
			If StringSplit($strImage, "-", 2)[0] = $element Then ExitLoop (2)
		Next
		$strImage = "unknown"
	WEnd

	Local $fileDir = "core\images\" & StringSplit($strImage, "-", 2)[0] & "\" & $strImage
	If FileExists($fileDir & ".bmp") Then
		#Region --- CodeWizard generated code Start ---
		;MsgBox features: Title=Yes, Text=Yes, Buttons=Yes, No, and Cancel, Icon=Warning, Modality=System Modal
		If Not IsDeclared("iMsgBoxAnswer") Then Local $iMsgBoxAnswer
		$iMsgBoxAnswer = MsgBox(4147, $botName & " " & $botVersion, ' "' & $strImage & '" already exist! Do you want to make an alternative image?')
		Select
			Case $iMsgBoxAnswer = 6 ;Yes
				Local $fileCounter = 2
				While FileExists($fileDir & $fileCounter & ".bmp")
					$fileCounter += 1 ;increment until file does not exist
				WEnd
				$fileDir = $fileDir & $fileCounter
			Case $iMsgBoxAnswer = 7 ;No
				Return Null
			Case $iMsgBoxAnswer = 2 ;Cancel
				Return Null
		EndSelect
		#EndRegion --- CodeWizard generated code Start ---
	EndIf
	_CaptureRegion($fileDir & ".bmp", $pointDebug1[0], $pointDebug1[1], $pointDebug2[0], $pointDebug2[1])
	MsgBox($MB_ICONINFORMATION, $botName & " " & $botVersion, "The image has been saved to: " & @CRLF & $fileDir & ".bmp")
EndFunc   ;==>btnSaveImage

;function: getEmulatorHandle()
;-stores window handle and control handle to global variable
;post:
;	-hHandle and hControl will be set to the new handle
;author: GkevinOD (2017)
Func getEmulatorHandle()
	$hWindow = WinGetHandle($botTitle)
	$hControl = ControlGetHandle($botTitle, "", $botInstance)

	$diff = ControlGetPos($botTitle, "", $hControl)
EndFunc   ;==>getEmulatorHandle
