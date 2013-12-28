#include <myprogress.au3>

$MyProgress_StepCount = 4
MyProgress_On(@ScriptName, "modern.IE Japanizer running.", "Started now.")
Sleep(1000)
MyProgress_Step("Done foo.")
Sleep(1000)
MyProgress_Step("Done bar." & @CRLF & "yay!")
Sleep(1000)
MyProgress_Step("Done baz.", "Cleaning up.")
Sleep(1000)
MyProgress_Step("", "Finished!")
Sleep(1000)
MyProgress_Off()
