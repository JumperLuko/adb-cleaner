#!/usr/bin/bash

if [ "$dialog_output" == "" ] || ! [ -e "$dialog_output" ]; then
	if [ -e "/usr/bin/dialog-output" ]; then
    	dialog_output="/usr/bin/dialog-output"
	elif [ -e "./dialog-output.sh" ]; then
		dialog_output="./dialog-output.sh"
	else
		echo "dialog-output not found"
		exit
	fi
fi

if ! [ -e "/usr/bin/adb" ]; then
	echo "adb not found"
	exit
fi

chooseOption(){
. $dialog_output --backtitle "ADB package cleaner" --default-item $1 --menu "Choose the option" 17 50 25\
 1 "List ADB devices"\
 2 "Search Packages names"\
 3 "Search running app"\
 4 "Disable app from user 0"\
 5 "Deny run in background"\
 6 "Deny run in background from list file"\
 7 "Stop process"\
 8 "Stop process from list file"\
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
	clear
	adb devices
}

adbSearch(){
	optionName="adb Search"
	. $dialog_output --inputbox "Search by package name:" 10 40
	clear
	adb shell pm list packages -e | grep "$DIALOG_RESULT"
}

adbSearchProcess(){
	. $dialog_output --inputbox "Search running app by package name:" 10 40
	clear
	adb shell ps | grep "$DIALOG_RESULT" | awk '{print $9}'
}

adbDisable(){
	optionName="adb disable app user 0"
	. $dialog_output --inputbox "Disable app user 0 by package name:" 10 40
	clear
	adb shell pm uninstall -k --user 0 $DIALOG_RESULT
}

adbDenyBackground(){
	optionName="adb stop app background"
	. $dialog_output --inputbox "Stop background app by package name:" 10 40
	clear
	adb shell appops set $DIALOG_RESULT RUN_IN_BACKGROUND deny
}

adbDenyBackgroundList(){
	. $dialog_output --title "Stop background app by package name" --fselect "" 8 50
	clear

	if [ "$DIALOG_RESULT" == "" ]; then
		DIALOG_RESULT="list.txt"
	fi

	for (( n=`cat $DIALOG_RESULT | wc -l`; n>0; n-- )); do
		line=`sed -n "$n"p "$DIALOG_RESULT"`
		echo $line
		adb shell appops set $line RUN_IN_BACKGROUND deny 2> /dev/null
		# if [ "$adbOutput" != "" ] ; then echo "error"; fi
		# else echo $line
	done
	unset line
}

adbForceStop(){
	. $dialog_output --inputbox "Stop process app by package name:" 10 40
	clear
	adb shell am force-stop $DIALOG_RESULT
}


adbForceStopList(){
	. $dialog_output --title "Stop process app by package name" --fselect "" 8 50
	clear

	if [ "$DIALOG_RESULT" == "" ]; then
		DIALOG_RESULT="list.txt"
	fi

	for (( n=`cat $DIALOG_RESULT | wc -l`; n>0; n-- )); do
		line=`sed -n "$n"p "$DIALOG_RESULT"`
		echo $line
		adb shell am force-stop $line 2> /dev/null
		# if [ "$adbOutput" != "" ] ; then echo "error"; fi
		# else echo $line
	done
	unset line
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
			adbSearchProcess;;
        4)
            adbDisable;;
        5)
            adbDenyBackground;;
		6)
			adbDenyBackgroundList;;
		7)
			adbForceStop;;
		8)
			adbForceStopList;;
		*)
			echo "Error";;
    esac
	again "$option"
done
