#include <Constants.au3>
#include <GuiTab.au3>

Func MyUtil_WinWaitActivate($title, $text = "", $timeout = 0)
	Local $hWnd = WinWait($title, $text, $timeout)
	If Not WinActive($hWnd) Then
		WinActivate($hWnd)
		WinWaitActive($hWnd)
	EndIf
	Return $hWnd
EndFunc

Func MyUtil_SelectTab($title, $text, $controlID, $sTabName)
	Local $hWnd = ControlGetHandle($title, $text, $controlID)
	If $hWnd = 0 Then
		Return -1
	EndIf
	Local $iIndex = _GUICtrlTab_FindTab($hWnd, $sTabName)
	If $iIndex = -1 Then
		Return -1
	EndIf
	_GUICtrlTab_SetCurFocus($hWnd, $iIndex)
	Return 0
EndFunc   ;==>MyUtil_SelectTab

Func MyUtil_ListViewGoToItem($title, $text, $controlID, $sItemText, $iSubItem)
	Local $iIndex = ControlListView($title, $text, $controlID, "FindItem", $sItemText, $iSubItem)
	If $iIndex = -1 Then
		Return -1
	EndIf

	Local $sKeys
	If $iIndex = 0 Then
		$sKeys = "{HOME}"
	Else
		$sKeys = "{HOME}{DOWN " & ($iIndex - 1) & "}"
	EndIf
	ControlSend($title, $text, $controlID, $sKeys)
	Return 0
EndFunc   ;==>MyUtil_ListViewGoToItem

Func MyUtil_ListViewGoToItemWithOffset($title, $text, $controlID, $sItemText, $iSubItem, $iOffset)
	Local $iIndex = ControlListView($title, $text, $controlID, "FindItem", $sItemText, $iSubItem)
	If $iIndex = -1 Then
		Return -1
	EndIf

	$iIndex = $iIndex + $iOffset
	Local $sKeys
	If $iIndex = 0 Then
		$sKeys = "{HOME}"
	Else
		$sKeys = "{HOME}{DOWN " & ($iIndex - 1) & "}"
	EndIf
	ControlSend($title, $text, $controlID, $sKeys)
	Return 0
EndFunc   ;==>MyUtil_ListViewGoToItemWithOffset

Func MyUtil_ControlWaitVisible($title, $text, $controlID)
	Do
		Sleep(100)
	Until ControlCommand($title, $text, $controlID, "IsVisible") = 1
EndFunc   ;==>MyUtil_ControlWaitVisible

Func MyUtil_Reboot()
	Shutdown(BitOR($SD_FORCE, $SD_REBOOT))
EndFunc   ;==>MyUtil_Reboot

Func MyUtil_RegWriteRunOnce($valuename, $value)
	Return RegWrite( _
			"HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunOnce", _
			$valuename, _
			"REG_SZ", _
			$value)
EndFunc   ;==>MyUtil_RegWriteRunOnce
