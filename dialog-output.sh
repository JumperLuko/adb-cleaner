#!/bin/bash

#? https://github.com/JumperLuko/dialog-output 

#! Variables with useful results
#! $DIALOG_RESULT
#! $DIALOG_CODE
#! $DIALOG_CODE_NAME

#! Uncomment to get results in terminal, or set these variables elsewhere
# DIALOG_ECHO_CODE=yes
# DIALOG_ECHO_CODE_FOREVER=yes
# DIALOG_ECHO_RESULT=yes
# DIALOG_ECHO_RESULT_FOREVER=yes

#! Maybe dialog is not installed, and in that case you want it to run other code automatically
# DIALOG_NOTFOUND_CODE(){ echo "My text exemple, if you don't have dialog installed"; read -p "type something: " DIALOG_RESULT;}
# DIALOG_NOTFOUND_FOREVER=yes

if [ "$dialog" == "" ] || ! [ -e "$dialog" ]; then
    dialog="/usr/bin/dialog"
fi

#! Checking if dialog is installed 
if [ -e "$dialog" ]; then
    #! Register outputs
    exec 3>&1
    DIALOG_RESULT=$("$dialog" "$@" 2>&1 1>&3)
    DIALOG_CODE="$?"
    exec 3>&-
elif [[ $(type -t DIALOG_NOTFOUND_CODE) != function ]] && ! [ -e "$dialog" ]; then
    echo "Dialog is not installed"
#! If you put yes in $DIALOG_NOTFOUND and dialog is not found, will execute DIALOG_NOTFOUND_CODE
elif [[ $(type -t DIALOG_NOTFOUND_CODE) == function ]] && ! [ -e "$dialog" ]; then
    DIALOG_NOTFOUND_CODE
fi

#! To run this funcion on every run, if dialog is not installed DIALOG_NOTFOUND_FOREVER=yes
if [ "$DIALOG_NOTFOUND_FOREVER" == "" ]; then
    unset -f DIALOG_NOTFOUND_CODE
fi

#! Define each error
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

#! echo exit code if DIALOG_ECHO_CODE=yes
echo_code(){
    if [ "$DIALOG_ECHO_CODE" != "" ] || [ "$DIALOG_ECHO_CODE_FOREVER" != "" ]; then
        echo "$1"
    fi
}

#! Act on the exit status
case $DIALOG_CODE in
$DIALOG_OK)
    DIALOG_CODE_NAME=DIALOG_OK;;
$DIALOG_CANCEL)
    DIALOG_CODE_NAME=DIALOG_CANCEL
    echo_code "Cancel pressed.";;
$DIALOG_HELP)
    DIALOG_CODE_NAME=DIALOG_HELP
    echo_code "Help pressed.";;
$DIALOG_EXTRA)
    DIALOG_CODE_NAME=DIALOG_EXTRA
    echo_code "Extra button pressed.";;
$DIALOG_ITEM_HELP)
    DIALOG_CODE_NAME=DIALOG_ITEM_HELP
    echo_code "Item-help button pressed.";;
$DIALOG_ESC)
    DIALOG_CODE_NAME=DIALOG_ESC
    echo_code "ESC pressed.";;
*)
    DIALOG_CODE_NAME=DIALOG_UNKNOWN;;
esac

unset DIALOG_OK DIALOG_CANCEL DIALOG_HELP DIALOG_EXTRA DIALOG_ITEM_HELP DIALOG_ESC

#! echo the code forever on every run if DIALOG_ECHO_RESULT_FOREVER=yes
if [ "$DIALOG_ECHO_CODE_FOREVER" == "" ]; then
    unset DIALOG_ECHO_CODE
fi

#! echo result if DIALOG_ECHO_RESULT=yes
if [ "$DIALOG_ECHO_RESULT" != "" ] || [ "$DIALOG_ECHO_RESULT_FOREVER" != "" ]; then
    echo $DIALOG_RESULT
fi

#! echo the result forever on every run if DIALOG_ECHO_RESULT_FOREVER=yes
if [ "$DIALOG_ECHO_RESULT_FOREVER" == "" ]; then
    unset DIALOG_ECHO_RESULT DIALOG_ECHO_CODE
fi