#!/bin/bash
#vmname='IE8 - Win7'
vmname='IE11 - Win8.1'

# NOTE: The --transient option does not work as expected here.
#       The guest vm cannot see the shared folder when using the --transient
#       option.
VBoxManage sharedfolder add "$vmname" --name 'share' --hostpath "$PWD"

VBoxManage startvm "$vmname" --type gui

if [ x"$1" = x"--no-run" ]; then
  exit 0
fi

sleep 20

# NOTE: "VBoxManage guestcontrol exec" does not work for an executable file in
#       a shared folder.
#VBoxManage guestcontrol "$vmname" exec --image '\\vboxsvr\share\japanize-modern-ie.exe' --username IEUser --password 'Passw0rd!'

# NOTE: You must split keyboardputscancode commands for a long key sequence.
# NOTE: Keycodes are depedent on keyboard types. The sequences below are for
#       US keyboards, and you must adjust them if you use Japanese keyboards.
# See "X (Set 2)" column for keycods at http://www.win.tue.nl/~aeb/linux/kbd/scancodes-10.html#scancodesets

# Press Windows-r
VBoxManage controlvm "$vmname" keyboardputscancode E0 5B 13 93 E0 DB
# Enter \\vboxsvr\share
VBoxManage controlvm "$vmname" keyboardputscancode 2B AB 2B AB 2F AF 30 B0 18 98 2D AD 1F 9F 2F AF 13 93 2B AB 1F 9F 23 A3 1E 9E 13 93 12 92
# Enter \japanize-modern
VBoxManage controlvm "$vmname" keyboardputscancode 2B AB 24 A4 1E 9E 19 99 1E 9E 31 B1 17 97 2C BC 12 92 0C 8C 32 B2 18 98 20 A0 12 92 13 93 31 B1
# Enter -ie.exe
VBoxManage controlvm "$vmname" keyboardputscancode 0C 8C 17 97 12 92 34 B4 12 92 2D AD 12 92
# Press enter
VBoxManage controlvm "$vmname" keyboardputscancode 1C 9C

# NOTE: We must press the button with caption &Run on the dialog titled
#       "Open File - Security Warning" which says
#       "We can't verify who created this file. Are you sure you want to
#       run this file?".
# Wait a second and press Alt-r
sleep 1
VBoxManage controlvm "$vmname" keyboardputscancode 38 13 93 A8
