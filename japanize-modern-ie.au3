#include <Constants.au3>
#include <myutil.au3>

HotKeySet("^!x", "MyExit")

If $CmdLine[0] = 0 Then
	ChangeTimeZoneToJST()
	InstallJapaneseLanguagePack()

	FileCopy(@ScriptFullPath, @TempDir)
	MyUtil_RegWriteRunOnce(@ScriptName, @TempDir & "\" & @ScriptName & " " & "step2")
	MyUtil_Reboot()
ElseIf $CmdLine[0] = 1 And $CmdLine[1] = "step2" Then
	ChangeDisplayLanguageToJapanese()
EndIf

Func InstallJapaneseLanguagePack()
	; >= Vista
	Run("control /name Microsoft.WindowsUpdate")
	$title = "Windows Update"
	Local $hWnd = WinWait($title)
	ControlClick($hWnd, "", "[CLASS:Button; TEXT:&Check for updates]")
	MyUtil_ControlWaitVisible($hWnd, "", "[CLASS:Button; TEXT:&Install updates]")

	; Go to important update list.
	ControlFocus($hWnd, "", "[CLASS:Button; TEXT:&Install updates]")
	Send("+{TAB}+{TAB}{SPACE}")
	Local $hWnd2 = WinWaitActive("Select updates to install")

	; Hide update of Internet Explorer 10 for Windows 7
	If MyUtil_ListViewGoToItem($hWnd2, "", "[CLASS:WuDuiListView; INSTANCE:1]", _
		"Internet Explorer 10 for Windows 7", 1) = 0 Then
		Send("{APPSKEY}{DOWN 2}{ENTER}")
		Sleep(1000)
	EndIf
	; Hide update of Internet Explorer 11 for Windows 7
	If MyUtil_ListViewGoToItem($hWnd2, "", "[CLASS:WuDuiListView; INSTANCE:1]", _
		"Internet Explorer 11 for Windows 7", 1) = 0 Then
		Send("{APPSKEY}{DOWN 2}{ENTER}")
		Sleep(1000)
	EndIf

	; Go back to the previous screen
	Send("!{LEFT}")
	$hWnd = WinWait($title)

	; Go to optional update list.
	ControlFocus($hWnd, "", "[CLASS:Button; TEXT:&Install updates]")
	Send("+{TAB}{SPACE}")
	$hWnd2 = WinWait("Select updates to install")

	; Check Japanese Language Pack
	Local Const $iItemCountInWindows7Section = 5
	If MyUtil_ListViewGoToItemWithOffset($hWnd2, "", "[CLASS:WuDuiListView; INSTANCE:1]", _
		"Japanese Language Pack - Windows 7 Service Pack 1 (KB2483139)", 1, _
		$iItemCountInWindows7Section + 1) = 0 Then
		Send("{SPACE}")
		Sleep(1000)
	Else
		MsgBox(0, @ScriptName, "japanese language pack not found in list", 5)
	EndIf

	ControlClick($hWnd, "", "[CLASS:Button; TEXT:OK]")
	WinWaitActive($title)
	ControlClick($hWnd, "", "[CLASS:Button; TEXT:&Install updates]")

	MyUtil_ControlWaitVisible($hWnd, "", "[CLASS:Button; TEXT:&Restart now]")
	ControlClick($hWnd, "", "[CLASS:Button; TEXT:&Restart now]")
EndFunc   ;==>InstallJapaneseLanguagePack

Func ChangeDisplayLanguageToJapanese()
	Run("control international")
	$title = "Region and Language"
	Local $hWnd = WinWait($title)

	MyUtil_SelectTab($hWnd, "", "[CLASS:SysTabControl32; INSTANCE:1]", "Formats")
	; Select Format
	ControlCommand($hWnd, "", "[CLASS:ComboBox; INSTANCE:1]", "SelectString", "Japanese (Japan)")

	MyUtil_SelectTab($hWnd, "", "[CLASS:SysTabControl32; INSTANCE:1]", "Location")
	; Select Current location
	ControlCommand($hWnd, "", "[CLASS:ComboBox; INSTANCE:1]", "SelectString", "Japan")

	MyUtil_SelectTab($hWnd, "", "[CLASS:SysTabControl32; INSTANCE:1]", "Keyboards and Languages")
	ControlClick($hWnd, "", "[CLASS:Button; TEXT:&Change keyboards...]")

	Local $hWnd2 = WinWait("Text Services and Input Languages")
	ControlClick($hWnd2, "", "[CLASS:Button; TEXT:A&dd...]")

	; Add Japanese IME to input language
	Local $hWnd3 = WinWait("Add Input Language")
	ControlTreeView($hWnd3, "", "[CLASS:SysTreeView32; INSTANCE:1]", "Expand", "Japanese (Japan)")
	ControlTreeView($hWnd3, "", "[CLASS:SysTreeView32; INSTANCE:1]", "Expand", "Japanese (Japan)|Keyboard")
	ControlTreeView($hWnd3, "", "[CLASS:SysTreeView32; INSTANCE:1]", "Check", "Japanese (Japan)|Keyboard|Microsoft IME")
	ControlClick($hWnd3, "", "[CLASS:Button; TEXT:OK]")

	; Choose Japanese IME as Default input language
	ControlCommand($hWnd2, "", "[CLASS:ComboBox; INSTANCE:1]", "SelectString", "Japanese (Japan) - Microsoft IME")
	ControlClick($hWnd2, "", "[CLASS:Button; TEXT:OK]")

	; Choose Japanese as Display Language
	ControlSend($hWnd, "", "[CLASS:ComboBox; INSTANCE:1]", "{DOWN}")
	ControlClick($hWnd, "", "[CLASS:Button; TEXT:OK]")

	Local $hWnd4 = WinWait("Change Display Language")

	; Prefer reboot to logoff because you don't have to input passwords manually.
	;ControlClick($hWnd4, "", "[CLASS:Button; TEXT:Log off now]")
	MyUtil_Reboot()
EndFunc   ;==>ChangeDisplayLanguageToJapanese

Func ChangeTimeZoneToJST()
	Run("control date/time")
	Local $hWnd = WinWait("Date and Time")
	ControlClick($hWnd, "", "[CLASS:Button; TEXT:Change time &zone...]")

	Local $hWnd2 = WinWait("Time Zone Settings")
	ControlCommand($hWnd2, "", "[CLASS:ComboBox; INSTANCE:1]", "SelectString", "(UTC+09:00) Osaka, Sapporo, Tokyo")
	ControlClick($hWnd2, "", "[CLASS:Button; TEXT:OK]")

	ControlClick($hWnd, "", "[CLASS:Button; TEXT:OK]")
EndFunc   ;==>ChangeTimeZoneToJST

Func MyExit()
	MsgBox(0, @ScriptName, "Aborting now because the hot-key was pressed.", 3);
	Exit
EndFunc
