#!/bin/bash

main() {
sleep 1
printf "\033[1;35mSimple Android file backup tool\nBy Liwhy\033[0m"
sleep 1
connection_check
backup_type
read finished
}

connection_check () {
# Check if adb is installed and accessible
if ! command -v adb &> /dev/null; then
  printf "\033[0;31m\nError: adb command not found. Please install Android Debug Bridge (adb) or run from correct directory.\033[0m"
  exit 1
fi

# Check for adb connection for 10 seconds
printf "\n\nChecking for adb connection...\n"
sleep 1
end=$(bc -l <<< "scale=2; $SECONDS + 10")
connection=false
while [[ $(($SECONDS < $end)) -eq 1 ]]; do
  if adb get-state 1>/dev/null 2>&1; then
     adb devices | grep 'device' | cut -f1
     connection=true
     break
  fi
done

sleep 1
# Check connection result
if [ "$connection" = false ]; then
  printf "\033[0;31m\nError: no devices found, check connection.\n\033[0m"
  exit 1
fi

}

# Prompt for backup type
backup_type () {
printf "\nSelect backup type: \n1: Full \n2: Partial"
printf "\nChoice: "
read choice
case "$choice" in
  1)
    if [ -d ~/Desktop/Backup/.backup ]; then
    printf "Old backup found: \n1: Merge \n2: Clear"
    printf "\nChoice: "
    read choice
    case "$choice" in
      1)
        ;;
      2)
        rm -rf ~/Desktop/Backup
        ;;
      *)
        sleep 1 
        backup_type
        ;;
    esac
    fi
    
    printf "\033[0;32m\n\nStarting full backup\n\033[0m"
    mkdir -p ~/Desktop/Backup/.backup
    cd ~/Desktop/Backup
    mkdir -p DCIM SwiftBackup Music Download Secure # Create backup folder structure
    
    # Backup images    
    printf "\nBacking up Images"
    cd ~/Desktop/Backup/DCIM
    mkdir -p Camera Snapchat
    adb pull -a -p /sdcard/DCIM/Camera temp # pull all files to temp folder
    adb pull -a -p /sdcard/Pictures temp
    find temp -type d -name 'Thumbnail' -exec rm -rf {} \; # remove thumbnail files
    find temp -type d -name '.thumbnails' -exec rm -rf {} \; 
    find temp -type f -exec mv {} temp/ \; # move all files to top of temp
    rm -rf temp/.[!.]* # remove hidden & deleted files
    find temp -type f -exec mv {} ~/Desktop/Backup/DCIM/Camera \; # move remaining files to Camera
    
    adb pull -a -p /sdcard/DCIM/Snapchat/ temp
    find temp -type f -exec mv {} temp/ \; # move all files to top of temp
    rm -rf temp/.[!.]* # remove hidden & deleted files
    find temp -type f -exec mv {} ~/Desktop/Backup/DCIM/Snapchat \; # move remaining files to Snapchat
    
    rm -rf temp # delete temp folder
    cd ~/Desktop/Backup
    
    # Backup Downloads
    printf "\nBacking up Download"
    adb pull -a -p /sdcard/Download/
    
    # Backup Music
    printf "\nBacking up Music"
    adb pull -a -p /sdcard/Music/
    
    # Backup SwiftBackup
    printf "\nBacking up SwiftBackup files"
    adb pull -a -p /sdcard/SwiftBackup/
    
    # Backup settings
    printf "\nBacking up settings, allow root access if prompted"
    adb shell "su -c cat /data/system/users/0/settings_system.xml" > Secure/settings_system.xml
    adb shell "su -c cat /data/system/users/0/settings_secure.xml" > Secure/settings_secure.xml
    
    printf "\033[0;32m\n\nBackup Finished\n\033[0m"
    ;;
  2)
    printf "\nNot implemented"
    backup_type
    ;;
  *)
    sleep 1
    backup_type
    ;;
esac
}


main "$@"; exit

#/data/system/users/0/settings_system.xml
#/data/system/users/0/settings_secure.xml
