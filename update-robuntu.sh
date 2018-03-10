#!/bin/bash

SCRIPT_NAME=`basename "$0"`
ARG="$1"
VERSION="1"
REVISION="3"
DATE="10 March 2018"
AUTHOR="Mr. Gallo"

TMP_FILE="/tmp/$SCRIPT_NAME"
LEVEL_FILE=~/.robuntu_update_level

main() {
    echo "UpdateRobuntu v$VERSION.$REVISION of $DATE, by $AUTHOR."
    echo
    
    if [ ! -f $LEVEL_FILE ]; then 
        echo "UpdateRobuntu was not installed properly. Missing $LEVEL_FILE!"
        exit 0
    fi
    
    CURRENT_LEVEL=$(head -1 $LEVEL_FILE)
    
    DO_LEVEL=$((CURRENT_LEVEL + 1))
    
    case "$DO_LEVEL" in
        # cascade with ;&

        1) do_update installTestModeScript_20180309  ;&           
        2) do_update fixBottomPanel_20180309         ;;
        *) echo "No updates." && exit 0
    esac
}


fixBottomPanel_20180309() {
    echo "Applying bottom panel lock and position adjustment"
    wget -q "https://raw.githubusercontent.com/MrGallo/bash-scripts/master/update-files/2/xfce4-panel.xml" -O ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
}

installTestModeScript_20180309() {
    echo "Installing test-mode script into /usr/local/bin."
    sudo wget -qO /usr/local/bin/test-mode.sh "https://raw.githubusercontent.com/MrGallo/bash-scripts/master/test-mode.sh"
    
    echo "Adding system alias 'test-mode'."
    echo "alias test-mode='bash test-mode.sh'" >> ~/.bash_aliases
    
    echo "Initializing git repository in home directory."
    echo "Could take a while..."
    cd ~
    git init && git add -A 
    git config --local user.name "robuntu"
    git config --local user.email "robuntu@stro.ycdsb.ca"
    git commit -m "Initial commit"
    echo "... Done!"
}

do_update () {
    $1  # run update

    # update level file
    CURRENT_LEVEL=$(($CURRENT_LEVEL + 1))
    echo $CURRENT_LEVEL > $LEVEL_FILE   
}

install () {
    FILE_PATH="/usr/local/bin/"
    if [ ! -f $FILE_PATH$SCRIPT_NAME ]; then
        sudo wget -O "$FILE_PATH$SCRIPT_NAME" "https://raw.githubusercontent.com/MrGallo/bash-scripts/master/$SCRIPT_NAME"
        echo "alias update-robuntu='bash $SCRIPT_NAME'" >> ~/.bash_aliases
        [ ! -f ~/.robuntu_update_level ] && echo "0" > ~/.robuntu_update_level
        
        echo "Running locally"
        bash $FILE_PATH$SCRIPT_NAME
        exit 0
    fi   
}

update () {
    # download most recent version
    
    wget -qO /tmp/"$SCRIPT_NAME" "https://raw.githubusercontent.com/MrGallo/bash-scripts/master/$SCRIPT_NAME" && {
        tmpFileV=$(head -5 $TMP_FILE | tail -1)
        tmpFileR=$(head -6 $TMP_FILE | tail -1)
        
        tmpFileV="${tmpFileV//[^0-9]/}"
        tmpFileV=$((10#$tmpFileV))
        
        tmpFileR="${tmpFileR//[^0-9]/}"
        tmpFileR=$((10#$tmpFileR))
        
        tmpFileVersion=$(( $tmpFileV * 1000 + $tmpFileR ))
        currentVersion=$(( $VERSION * 1000 + $REVISION ))
        
        if (( tmpFileVersion > currentVersion )); then 
            #echo "Newer version found."
            echo "Updating to latest version."
            cp "$TMP_FILE" "$0"
            rm -f "$TMP_FILE"
            
            #echo "Running updated version..."
            bash $0
            exit 0
        else
            #echo "Current version up to date."
            rm -f "$TMP_FILE"
        fi
    }
}


install
update
main
