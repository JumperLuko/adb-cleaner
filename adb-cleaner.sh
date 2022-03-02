#!/usr/bin/bash

if [ "$dialog_output" == "" ] || ! [ -e "$dialog_output" ]; then
	if [ -e "/usr/bin/dialog-output" ]; then
    	dialog_output="/usr/bin/dialog-output"
	elif [ -e "./dialog-output" ]; then
		dialog_output="./dialog-output"
	else
		echo "dialog-output not found"
		exit
	fi
fi

chooseOption(){
. $dialog_output --backtitle "ADB package cleaner" --default-item $1 --menu "Choose the option" 12 45 25\
 1 "List ADB devices"\
 2 "Search Packages names"\
 3 "Disable app from user 0"\
 4 "Deny run in background"\
 0 "Exit"
option=$DIALOG_RESULT
optionCode=$DIALOG_CODE
}
chooseOption "1"

again(){
	echo ""
	read -p "Enter to continue"
	chooseOption "$1"
}

adbDevices(){
	optionName="adb devices"
	echo -e "\n"
	adb devices
}

adbSearch(){
	optionName="adb Search"
	. $dialog_output --inputbox "Search by package name:" 10 40
	echo -e "\n"
	adb shell pm list packages -e | grep "$DIALOG_RESULT"
}

adbDisable(){
	optionName="adb disable app user 0"
	. $dialog_output --inputbox "Disable app user 0 by package name:" 10 40
	echo -e "\n"
	adb shell pm uninstall -k --user 0 $DIALOG_RESULT
}

adbDenyBackground(){
	optionName="adb stop app background"
	. $dialog_output --inputbox "Stop background app by package name:" 10 40
	echo -e "\n"
	adb shell appops set $DIALOG_RESULT RUN_IN_BACKGROUND deny
}

while [ "$option" != 0 ] && [ "$optionCode" == 0 ]; do
	clear
    case $option in
        0|255) 
			echo "Exit";;
        1) 
            adbDevices;;
        2)
            adbSearch;;
        3)
            adbDisable;;
        4)
            adbDenyBackground;;
		*)
			echo "Error";;
    esac
	again "$option"
done
