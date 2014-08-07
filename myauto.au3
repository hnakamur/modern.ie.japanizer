#include "UIAWrappers.au3"

Func MyAuto_FindTopLevelWindow($wndSpec)
   Local $oWnd = _UIA_getFirstObjectOfElement($UIA_oDesktop, $wndSpec, $TreeScope_Children)
   If Not IsObj($oWnd) Then
	  ConsoleWrite("Window not found: " & $wndSpec & @CRLF)
	  Exit 1
   EndIf

   Return $oWnd
EndFunc

Func MyAuto_DoesObjectExist($oWnd, $objSpec)
   Local $obj = _UIA_getObjectByFindAll($oWnd, $objSpec, $TreeScope_SubTree)
   Return IsObj($obj)
EndFunc

Func MyAuto_WaitForObjectToAppear($oWnd, $objSpec)
   While Not MyAuto_DoesObjectExist($oWnd, $objSpec)
	  Sleep(1000)
   WEnd
EndFunc

Func MyAuto_WaitUntilObjectDisappear($oWnd, $objSpec)
   While MyAuto_DoesObjectExist($oWnd, $objSpec)
	  Sleep(1000)
   WEnd
EndFunc

Func MyAuto_ClickObject($oWnd, $objSpec)
   Local $obj = _UIA_getObjectByFindAll($oWnd, $objSpec, $TreeScope_SubTree)
   If Not IsObj($obj) Then
	  ConsoleWrite("Object not found: " & $objSpec & @CRLF)
	  Exit 1
   EndIf

   _UIA_action($obj, "focus")
   _UIA_action($obj, "click")
EndFunc