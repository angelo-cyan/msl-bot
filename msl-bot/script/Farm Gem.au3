#cs
	Function: farmGem
	Calls farmGemMain with config settings

	Author: GkevinOD (2017)
#ce
Func farmGem()
	Local $justEvolve = IniRead(@ScriptDir & "/" & $botConfig, "Farm Gem", "just-evolve", 1)
	Local $monster = IniRead(@ScriptDir & "/" & $botConfig, "Farm Gem", "monster", "slime")
	Local $maxGold = IniRead(@ScriptDir & "/" & $botConfig, "Farm Gem", "max-gold", 330000)
	Local $maxRefill = IniRead(@ScriptDir & "/" & $botConfig, "Farm Gem", "refill-max-gem", 30)

	If $justEvolve = 1 Then
		If MsgBox(8193, "Farm Gem WARNING", "WARNING: You must have at least 330k gold for this script to function correctly!" & @CRLF & "**LOCK YOUR GLEEMS.") = 2 Then Return -1
	Else
		If MsgBox(8193, "Farm Gem WARNING", "WARNING: You must have at least 330k gold and 16 spaces in your astromon storage for this script to function correctly!" & @CRLF & "Also average energy per 16 astromons is 40, make sure you refill to make things more smooth." & @CRLF & "**LAST THING LOCK YOUR GLEEMS.") = 2 Then Return -1
		Do
			Local $freeSpace = InputBox("Free Gem Input", "Enter number of free space in your Astromon Inventory: " & @CRLF & "(Must be greater than or equal to 16)", "16")
			If @Error = 1 Then Return -1
		Until StringIsDigit($freeSpace) = True And $freeSpace >= 16
	EndIf

	setLog("~~~Starting 'Farm Gem' script~~~", 2)
	farmGemMain($monster, $justEvolve, $maxGold, $maxRefill)
	setLog("~~~Finished 'Farm Gem' script~~~", 2)
EndFunc   ;==>farmGem

#cs ----------------------------------------------------------------------------
	Function: farmGemMain
	Farm astromon and evo to get 100 gems

	Parameter:
		monster: (String) Monster to farm with, current available: slime
		justEvolve: (Int) 1=True; 0=False
		maxGold: (Int) Max gold bot can use
		refillMax: (Int) Maximum gems bot can use for refill

	Author: GkevinOD (2017)
#ce ----------------------------------------------------------------------------

Func farmGemMain($monster, $justEvolve, $maxGold, $maxRefill)
	Switch $monster
		Case "slime"
			Local $imgName = "catch-one-star"
			Local $map = "map-phantom-forest"
	EndSwitch

	Local $numIteration = Floor(Int($maxGold)/330000)
	If setLog("Total number of iteration: " & $numIteration & ", " & 100*$numIteration & " gems.", 2) Then Return
	While $numIteration > 0
		If $justEvolve = 0 Then
			If setLog("Going to collect 16 " & $monster & "s..", 2) Then Return

			;Going into battle to farm astromons
			If navigate("map") = False Then
				setLog("Error: Could not go into maps!", 2)
				Return
			EndIf

			If enterStage("map-phantom-forest", "normal", "any", False) = False Then
				setLog("Error: Could not go into battle!", 2)
				Return
			EndIf

			;calling farmAstromon script to farm 16 monsters
			farmAstromonMain("catch-one-star", 16, 0, 0, 30)
			$maxRefill -= 30
		EndIf

		;going back to village to manage
		If setLog("Going to evolve " & $monster & "..", 2) Then Return
		If evolve("monster-" & $monster) = False Then
			setLog("Error: Something went wrong in the evolving process!", 2)
			Return
		EndIf

		$numIteration -= 1
	WEnd
EndFunc   ;==>farmGemMain