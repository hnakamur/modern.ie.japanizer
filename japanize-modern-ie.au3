#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Run_Tidy=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Constants.au3>
#include <myprogress.au3>
#include <myutil.au3>

HotKeySet("^!x", "MyExit")

If @OSVersion = "Win_81" Or @OSVersion = "Win_8" Then
	JapanizeWin8()
ElseIf @OSVersion = "Win_7" Then
	JapanizeWin7()
Else
	MsgBox(0, "modern.IE Japanizer", "This version of Windows is not supported. OSVersion=" & @OSVersion)
EndIf
Exit

Func JapanizeWin8()
	$MyProgress_StepCount = 8
	MyProgress_On("modern.IE Japanizer", _
			"Start GUI automation.", _
			"Do not touch mouse nor keyboard while running.")

	ChangeTimeZoneToJST()
	ChangeRegsionWin8()

	Run("control /name Microsoft.Language")

	WinWaitActive("Language")
	Send("j{ENTER}")

	MyProgress_Step('Waiting for "Download and install language pack" link.', _
			"Install Japanese language pack.")

	Local $hWnd = WinWaitActive("Language options")
	Sleep(10000)
	ControlFocus($hWnd, "", "[CLASS:Button; TEXT:Cancel]")
	Send("{TAB 4}{SPACE}")

	MyProgress_Step("Waiting for download and install...", _
			"Install Japanese language pack")

	WinWaitActive("Download and Install Updates")
	MyUtil_ControlWaitVisible("Download and Install Updates", "", "[CLASS:Button; TEXT:Close]")

	MyProgress_Off()
	MsgBox(0, "modern.IE Japanizer", 'Press Close button on "Download and Install Updates" MANUALLY.')
	MyProgress_On("modern.IE Japanizer", _
			"Change default language", _
			"Make Japanese the primary languge.")
	Sleep(2000)

	MyUtil_WinWaitActivate("Language")
	Send("{ENTER}")

	$hWnd = WinWait("Language options")
	ControlFocus($hWnd, "", "[CLASS:Button; TEXT:Cancel]")
	Send("{TAB 3}{SPACE}")

	WinWaitActive("Change display language")

	MyProgress_Step("Will reboot to take effect of Japanization now.", _
			"Complete")
	Sleep(5000)

	MyUtil_Reboot()
EndFunc   ;==>JapanizeWin8

Func JapanizeWin7()
	$MyProgress_StepCount = 19
	If $CmdLine[0] = 0 Then
		MyProgress_On("modern.IE Japanizer", _
				"Start GUI automation.", _
				"Do not touch mouse nor keyboard while running.")
		ChangeTimeZoneToJST()
		InstallJapaneseLanguagePack()

		MyProgress_Step("Will continue processing after rebooting.", _
				"Reboot needed to use Japanese language pack.")
		Sleep(1000)

		FileCopy(@ScriptFullPath, @TempDir)
		MyUtil_RegWriteRunOnce(@ScriptName, @TempDir & "\" & @ScriptName & " " & "step2")
		MyUtil_Reboot()
	ElseIf $CmdLine[0] = 1 And $CmdLine[1] = "step2" Then
		MyProgress_On("modern.IE Japanizer", _
				"Continue GUI automation.")
		$MyProgress_StepIndex = 10
		MyProgress_Step("Do not touch mouse nor keyboard while running.")
		Sleep(1000)

		ChangeDisplayLanguageToJapanese()

		MyProgress_Step("Will reboot to take effect.", _
				"Reboot preferred to Logging off to avoid typing password.")
		Sleep(1000)

		MyUtil_RegWriteRunOnce(@ScriptName, @TempDir & "\" & @ScriptName & " " & "step3")
		MyUtil_Reboot()
	ElseIf $CmdLine[0] = 1 And $CmdLine[1] = "step3" Then
		MyProgress_On("modern.IE Japanizer", _
				"日本語環境のセットアップが完了しました。")
		MyProgress_Set(100)
		Sleep(5000)
		MyProgress_Off()
	EndIf
EndFunc   ;==>JapanizeWin7

Func InstallJapaneseLanguagePack()
	MyProgress_Step("Checking updates...", "Install Windows Update.")

	; >= Vista
	Run("control /name Microsoft.WindowsUpdate")
	$title = "Windows Update"
	Local $hWnd = WinWait($title)
	ControlClick($hWnd, "", "[CLASS:Button; TEXT:&Check for updates]")
	MyUtil_ControlWaitVisible($hWnd, "", "[CLASS:Button; TEXT:&Install updates]")
	MyProgress_Step("Update check done.")

	; Go to important update list.
	ControlFocus($hWnd, "", "[CLASS:Button; TEXT:&Install updates]")
	Send("+{TAB}+{TAB}{SPACE}")
	Local $hWnd2 = WinWaitActive("Select updates to install")

	; Hide update of Internet Explorer 10 for Windows 7
	If MyUtil_ListViewGoToItem($hWnd2, "", "[CLASS:WuDuiListView; INSTANCE:1]", _
			"Internet Explorer 10 for Windows 7", 1) = 0 Then
		Send("{APPSKEY}{DOWN 2}{ENTER}")
		MyProgress_Step("Hide update of Internet Explorer 10 for Windows 7")
		Sleep(1000)
	EndIf
	; Hide update of Internet Explorer 11 for Windows 7
	If MyUtil_ListViewGoToItem($hWnd2, "", "[CLASS:WuDuiListView; INSTANCE:1]", _
			"Internet Explorer 11 for Windows 7", 1) = 0 Then
		Send("{APPSKEY}{DOWN 2}{ENTER}")
		MyProgress_Step("Hide update of Internet Explorer 11 for Windows 7")
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
		MyProgress_Step("Selected Japanese Language Pack to install")
		Sleep(1000)
	Else
		MsgBox(0, @ScriptName, "japanese language pack not found in list", 5)
	EndIf

	MyProgress_Step("Installing Japanese language pack and other updates.")
	ControlClick($hWnd, "", "[CLASS:Button; TEXT:OK]")
	WinWaitActive($title)
	ControlClick($hWnd, "", "[CLASS:Button; TEXT:&Install updates]")

	; Wait for [Restart now] button, but don't press it.
	MyUtil_ControlWaitVisible($hWnd, "", "[CLASS:Button; TEXT:&Restart now]")
	MyProgress_Step("Finished installation.")
	Sleep(1000)
EndFunc   ;==>InstallJapaneseLanguagePack

Func ChangeRegsionWin8()
	MyProgress_Step("Start processing.", "Change Region.")

	Run("control international")
	Local $hWnd = WinWait("Region")

	MyUtil_SelectTab($hWnd, "", "[CLASS:SysTabControl32; INSTANCE:1]", "Location")
	ControlCommand($hWnd, "", "[CLASS:ComboBox; INSTANCE:1]", "SelectString", "Japan")
	MyProgress_Step("Changed location.")
	Sleep(2000)

	MyUtil_SelectTab($hWnd, "", "[CLASS:SysTabControl32; INSTANCE:1]", "Administrative")
	ControlClick($hWnd, "", "[CLASS:Button; TEXT:&Change system locale...]")

	Local $hWnd2 = WinWaitActive("Change Regional Options")
	ControlClick($hWnd2, "", "[CLASS:Button; TEXT:Apply]")

	Local $hWnd3 = WinWaitActive("Region Settings")
	ControlCommand($hWnd3, "", "[CLASS:ComboBox; INSTANCE:1]", "SelectString", "Japanese (Japan)")
	ControlClick($hWnd3, "", "[CLASS:Button; TEXT:OK]")

	Local $hWnd4 = WinWait("Change System Locale")
	ControlClick($hWnd4, "", "[CLASS:Button; TEXT:Cancel]")

	MyProgress_Step("Changed system locale.", "Change Region.")
	Sleep(2000)
EndFunc   ;==>ChangeRegsionWin8

Func ChangeDisplayLanguageToJapanese()
	MyProgress_Step("Start processing.", "Change Display Language.")

	Run("control international")
	$title = "Region and Language"
	Local $hWnd = WinWait($title)

	MyUtil_SelectTab($hWnd, "", "[CLASS:SysTabControl32; INSTANCE:1]", "Formats")
	; Select Format
	ControlCommand($hWnd, "", "[CLASS:ComboBox; INSTANCE:1]", "SelectString", "Japanese (Japan)")
	MyProgress_Step("Changed format.")

	MyUtil_SelectTab($hWnd, "", "[CLASS:SysTabControl32; INSTANCE:1]", "Location")
	; Select Current location
	ControlCommand($hWnd, "", "[CLASS:ComboBox; INSTANCE:1]", "SelectString", "Japan")
	MyProgress_Step("Changed location.")

	MyUtil_SelectTab($hWnd, "", "[CLASS:SysTabControl32; INSTANCE:1]", "Keyboards and Languages")
	ControlClick($hWnd, "", "[CLASS:Button; TEXT:&Change keyboards...]")

	Local $hWnd2 = WinWait("Text Services and Input Languages")
	ControlClick($hWnd2, "", "[CLASS:Button; TEXT:A&dd...]")
	MyProgress_Step("Added keyboard.")

	; Add Japanese IME to input language
	Local $hWnd3 = WinWait("Add Input Language")
	ControlTreeView($hWnd3, "", "[CLASS:SysTreeView32; INSTANCE:1]", "Expand", "Japanese (Japan)")
	ControlTreeView($hWnd3, "", "[CLASS:SysTreeView32; INSTANCE:1]", "Expand", "Japanese (Japan)|Keyboard")
	ControlTreeView($hWnd3, "", "[CLASS:SysTreeView32; INSTANCE:1]", "Check", "Japanese (Japan)|Keyboard|Microsoft IME")
	ControlClick($hWnd3, "", "[CLASS:Button; TEXT:OK]")
	MyProgress_Step("Added Japanese IME.")

	; Choose Japanese IME as Default input language
	ControlCommand($hWnd2, "", "[CLASS:ComboBox; INSTANCE:1]", "SelectString", "Japanese (Japan) - Microsoft IME")
	ControlClick($hWnd2, "", "[CLASS:Button; TEXT:OK]")
	MyProgress_Step("Set Japanese IME as default.")

	; Choose Japanese as Display Language
	ControlSend($hWnd, "", "[CLASS:ComboBox; INSTANCE:1]", "{DOWN}")
	ControlClick($hWnd, "", "[CLASS:Button; TEXT:OK]")

	MyProgress_Step("Done processing.")
	Sleep(1000)
EndFunc   ;==>ChangeDisplayLanguageToJapanese

Func ChangeTimeZoneToJST()
	MyProgress_Step("Start processing.", "Change Time Zone to JST.")

	Run("control date/time")
	Local $hWnd = WinWait("Date and Time")
	ControlClick($hWnd, "", "[CLASS:Button; TEXT:Change time &zone...]")

	Local $hWnd2 = WinWait("Time Zone Settings")
	ControlCommand($hWnd2, "", "[CLASS:ComboBox; INSTANCE:1]", "SelectString", "(UTC+09:00) Osaka, Sapporo, Tokyo")
	ControlClick($hWnd2, "", "[CLASS:Button; TEXT:OK]")

	ControlClick($hWnd, "", "[CLASS:Button; TEXT:OK]")

	MyProgress_Step("Done processing.")
	Sleep(1000)
EndFunc   ;==>ChangeTimeZoneToJST

Func MyExit()
	MyProgress_Off()
	MsgBox(0, @ScriptName, "Aborting now because the hot-key was pressed.", 3);
	Exit
EndFunc   ;==>MyExit
