#include <Constants.au3>

Global $MyProgress_StepIndex = 0
Global $MyProgress_StepCount = 100
Global $MyProgress_MainText = ""

; NOTE: $MyProgress_SubTextSuffix must be one line text.
Global $MyProgress_SubTextSuffix = _
		"Press alt+shift+x to stop if GUI automation goes wrong."

Func MyProgress_buildSubText($subtext)
	If StringInStr($subtext, @CRLF) = 0 Then
		Return $subtext & @CRLF & @CRLF & $MyProgress_SubTextSuffix
	Else
		Return $subtext & @CRLF & $MyProgress_SubTextSuffix
	EndIf
EndFunc   ;==>MyProgress_buildSubText

; NOTE: $subtext must be one or two lines.
Func MyProgress_On($title, $maintext, $subtext = "", $x = -1, $y = -1, $opt = -1)
	If $opt = -1 Then
		$opt = $DLG_MOVEABLE
	EndIf
	$MyProgress_MainText = $maintext
	ProgressOn($title, $maintext, MyProgress_buildSubText($subtext), $x, $y, $opt)
EndFunc   ;==>MyProgress_On

Func MyProgress_Step($subtext = "", $maintext = "")
	$MyProgress_StepIndex = $MyProgress_StepIndex + 1
	Local $percent = 100 * $MyProgress_StepIndex / $MyProgress_StepCount
	If $maintext <> "" Then
		$MyProgress_MainText = $maintext
	EndIf
	ProgressSet($percent, MyProgress_buildSubText($subtext), $MyProgress_MainText)
EndFunc   ;==>MyProgress_Step

Func MyProgress_Set($percent, $subtext = "", $maintext = "")
	If $maintext <> "" Then
		$MyProgress_MainText = $maintext
	EndIf
	ProgressSet($percent, MyProgress_buildSubText($subtext), $MyProgress_MainText)
EndFunc   ;==>MyProgress_Set

Func MyProgress_Off()
	ProgressOff()
EndFunc   ;==>MyProgress_Off
