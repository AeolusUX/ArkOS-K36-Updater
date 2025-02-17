#!/bin/bash
clear
UPDATE_DATE="02092025"
LOG_FILE="/home/ark/update$UPDATE_DATE.log"
UPDATE_DONE="/home/ark/.config/.update$UPDATE_DATE"

if [ -f "$UPDATE_DONE" ]; then
	msgbox "No more updates available.  Check back later."
	rm -- "$0"
	exit 187
fi

if [ -f "$LOG_FILE" ]; then
	sudo rm "$LOG_FILE"
	sudo rm "$LOG_FILE"
fi

LOCATION="https://raw.githubusercontent.com/AeolusUX/ArkOS-K36-Updater/main"
ISITCHINA="$(curl -s --connect-timeout 30 -m 60 http://demo.ip-api.com/json | grep -Po '"country":.*?[^\\]"')"

if [ "$ISITCHINA" = "\"country\":\"China\"" ]; then
  printf "\n\nSwitching to China server for updates.\n\n" | tee -a "$LOG_FILE"
  LOCATION="https://raw.githubusercontent.com/AeolusUX/ArkOS-K36-Updater/main"
fi

sudo msgbox "MAKE SURE YOU SWITCHED TO MAIN SD FOR ROMS BEFORE YOU RUN THIS UPDATE. ONCE YOU PROCEED WITH THIS UPDATE SCRIPT, DO NOT STOP THIS SCRIPT UNTIL IT IS COMPLETED OR THIS DISTRIBUTION MAY BE LEFT IN A STATE OF UNUSABILITY.  Make sure you've created a backup of this sd card as a precaution in case something goes very wrong with this process.  You've been warned!  Type OK in the next screen to proceed."
my_var=`osk "Enter OK here to proceed." | tail -n 1`

#sudo msgbox "UPDATER IS CURRENTLY UNAVAILABLE. IT WILL BE BACK AGAIN, SOON."
#my_var=`osk "TRY AGAIN LATER" | tail -n 1`

echo "$my_var" | tee -a "$LOG_FILE"

#if [ "$my_var" != "test" ] && [ "$my_var" != "TEST" ]; then
if [ "$my_var" != "ok" ] && [ "$my_var" != "OK" ]; then

  sudo msgbox "You didn't type OK.  This script will exit now and no changes have been made from this process."
  printf "You didn't type OK.  This script will exit now and no changes have been made from this process." | tee -a "$LOG_FILE"	
  exit 187
fi

c_brightness="$(cat /sys/devices/platform/backlight/backlight/backlight/brightness)"
sudo chmod 666 /dev/tty1
echo 255 > /sys/devices/platform/backlight/backlight/backlight/brightness
touch $LOG_FILE
tail -f $LOG_FILE >> /dev/tty1 &


if [ ! -f "$UPDATE_DONE" ]; then

	printf "\nChange netplay check frame setting to 10 for rk3326 devices\nUpdate singe.sh to include -texturestream setting\nUpdate daphne.sh to include -texturestream setting\nUpdate netplay.sh\nOptimize hostapd.conf\nAdd Restore ECWolf joystick control tool\nUpdate Backup and Restore ArkOS Settings tools\nUpdate ES to add scraping for vircon32\nUpdate XRoar emulator to version 1.6.5\nFix Kodi 21 crash playing large movies\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/09272024/arkosupdate09272024.zip -O /dev/shm/arkosupdate09272024.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate09272024.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate09272024.zip" ]; then
	  if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
		sudo unzip -X -o /dev/shm/arkosupdate09272024.zip -d / | tee -a "$LOG_FILE"
	    sudo rm -f /usr/lib/aarch64-linux-gnu/libass.so.9
	    sudo ln -sfv /usr/lib/aarch64-linux-gnu/libass.so.9.2.1 /usr/lib/aarch64-linux-gnu/libass.so.9
	  else
		sudo unzip -X -o /dev/shm/arkosupdate09272024.zip -x usr/lib/aarch64-linux-gnu/libass.so.9.2.1 -d / | tee -a "$LOG_FILE"
	  fi
	  printf "\nAdd PuzzleScript emulator\n" | tee -a "$LOG_FILE"
	  if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep 'puzzlescript' | tr -d '\0')"
	  then
	    cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update09272024.bak | tee -a "$LOG_FILE"
	    sed -i -e '/<theme>piece<\/theme>/{r /home/ark/add_puzzlescript.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
	  fi
	  if [ ! -d "/roms/puzzlescript" ]; then
	    mkdir -v /roms/puzzlescript | tee -a "$LOG_FILE"
	    if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	    then
		  if [ ! -d "/roms2/puzzlescript" ]; then
		    mkdir -v /roms2/puzzlescript | tee -a "$LOG_FILE"
		    sed -i '/<path>\/roms\/puzzlescript/s//<path>\/roms2\/puzzlescript/g' /etc/emulationstation/es_systems.cfg
		  fi
	    fi
	  fi
	  if [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ]; then
	    if test -z "$(cat /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | grep puzzlescript | tr -d '\0')"
	    then
		  sudo chown -v ark:ark /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | tee -a "$LOG_FILE"
		  sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/puzzlescript\/" ]\; then\n      sudo mkdir \/roms2\/puzzlescript\n  fi\n  sudo pkill filebrowser/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
	    else
		  printf "\npuzzlescript is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	    fi
	  fi
	  if [ -f "/usr/local/bin/Switch to SD2 for Roms.sh" ]; then
	    if test -z "$(cat /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh | grep puzzlescript | tr -d '\0')"
	    then
		  sudo sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/puzzlescript\/" ]\; then\n      sudo mkdir \/roms2\/puzzlescript\n  fi\n  sudo pkill filebrowser/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
	    else
		  printf "\npuzzlescript is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	    fi
	  fi
	  printf "\nAdd Vircon32 emulator\n" | tee -a "$LOG_FILE"
	  if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep 'vircon32' | tr -d '\0')"
	  then
	    cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update09272024.bak | tee -a "$LOG_FILE"
	    sed -i -e '/<theme>tvc<\/theme>/{r /home/ark/add_vircon32.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
	  fi
	  if [ ! -d "/roms/vircon32" ]; then
	    mkdir -v /roms/vircon32 | tee -a "$LOG_FILE"
	    if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	    then
		  if [ ! -d "/roms2/vircon32" ]; then
		    mkdir -v /roms2/vircon32 | tee -a "$LOG_FILE"
		    sed -i '/<path>\/roms\/vircon32/s//<path>\/roms2\/vircon32/g' /etc/emulationstation/es_systems.cfg
		  fi
	    fi
	  fi
	  if [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ]; then
	    if test -z "$(cat /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | grep vircon32 | tr -d '\0')"
	    then
		  sudo chown -v ark:ark /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | tee -a "$LOG_FILE"
		  sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/vircon32\/" ]\; then\n      sudo mkdir \/roms2\/vircon32\n  fi\n  sudo pkill filebrowser/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
	    else
		  printf "\nVircon32 is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	    fi
	  fi
	  if [ -f "/usr/local/bin/Switch to SD2 for Roms.sh" ]; then
	    if test -z "$(cat /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh | grep vircon32 | tr -d '\0')"
	    then
		  sudo sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/vircon32\/" ]\; then\n      sudo mkdir \/roms2\/vircon32\n  fi\n  sudo pkill filebrowser/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
	    else
		  printf "\nVircon32 is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	    fi
	  fi
	  sudo rm -fv /home/ark/add_vircon32.txt | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/add_puzzlescript.txt | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate09272024.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate09272024.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	printf "\nAdd .m3u and .M3U to supported extensions for Amiga and Amiga CD32\n" | tee -a "$LOG_FILE"
	sed -i '/<extension>.adf .ADF .hdf .HDF .ipf .IPF .lha .LHA .zip .ZIP/s//<extension>.adf .ADF .hdf .HDF .ipf .IPF .lha .LHA .m3u .M3U .zip .ZIP/' /etc/emulationstation/es_systems.cfg
	sed -i '/<extension>.chd .CHD .cue .CUE .ccd .CCD .lha .LHA .nrg .NRG .mds .MDS .iso .ISO/s//<extension>.ccd .CCD .chd .CHD .cue .CUE .iso .ISO .lha .LHA .m3u .M3U .mds .MDS .nrg .NRG/' /etc/emulationstation/es_systems.cfg

	printf "\nCopy correct libretro puzzlescript core depending on device\n" | tee -a "$LOG_FILE"
	if [ ! -f "/boot/rk3566.dtb" ] && [ ! -f "/boot/rk3566-OC.dtb" ]; then
	  mv -fv /home/ark/.config/retroarch/cores/puzzlescript_libretro.so.rk3326 /home/ark/.config/retroarch/cores/puzzlescript_libretro.so | tee -a "$LOG_FILE"
	else
	  rm -fv /home/ark/.config/retroarch/cores/puzzlescript_libretro.so.rk3326 | tee -a "$LOG_FILE"
	fi

	if [ ! -f "/boot/rk3566.dtb" ] && [ ! -f "/boot/rk3566-OC.dtb" ]; then
	  printf "\nChange default netplay check frame setting to 10\n" | tee -a "$LOG_FILE"
	  sed -i '/netplay_check_frames \=/c\netplay_check_frames \= "10"' /home/ark/.config/retroarch/retroarch.cfg
	  sed -i '/netplay_check_frames \=/c\netplay_check_frames \= "10"' /home/ark/.config/retroarch32/retroarch.cfg
	  sed -i '/netplay_check_frames \=/c\netplay_check_frames \= "10"' /home/ark/.config/retroarch/retroarch.cfg.bak
	  sed -i '/netplay_check_frames \=/c\netplay_check_frames \= "10"' /home/ark/.config/retroarch32/retroarch.cfg.bak
	fi

	printf "\nCopy correct emulationstation depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-r33s-linux.dtb" ] || [ -f "/boot/rk3326-r35s-linux.dtb" ] || [ -f "/boot/rk3326-r36s-linux.dtb" ] || [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  sudo mv -fv /home/ark/emulationstation.351v /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-odroidgo2-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ] || [ -f "/boot/rk3326-odroidgo3-linux.dtb" ]; then
	  test=$(stat -c %s "/usr/bin/emulationstation/emulationstation")
	  if [ "$test" = "3416928" ]; then
	    sudo cp -fv /home/ark/emulationstation.351v /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  elif [ -f "/home/ark/.config/.DEVICE" ]; then
		sudo cp -fv /home/ark/emulationstation.rgb10max /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  else
	    sudo cp -fv /home/ark/emulationstation.header /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  fi
	  if [ -f "/home/ark/.config/.DEVICE" ]; then
	    sudo cp -fv /home/ark/emulationstation.rgb10max /usr/bin/emulationstation/emulationstation.header | tee -a "$LOG_FILE"
	  else
	    sudo cp -fv /home/ark/emulationstation.header /usr/bin/emulationstation/emulationstation.header | tee -a "$LOG_FILE"
	  fi
	  sudo cp -fv /home/ark/emulationstation.351v /usr/bin/emulationstation/emulationstation.fullscreen | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  sudo mv -fv /home/ark/emulationstation.503 /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	fi

	printf "\nInstall and link new SDL 2.0.3000.7 (aka SDL 2.0.30.7)\n" | tee -a "$LOG_FILE"
	  sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.3000.7.rk3326 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.7 | tee -a "$LOG_FILE"
	  sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.3000.7.rk3326 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.7 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.7 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.7 /usr/lib/arm-linux-gnueabihf/libSDL2.so | tee -a "$LOG_FILE"


	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)(AeUX)" /usr/share/plymouth/themes/text.plymouth
	
	touch "$UPDATE_DONE"
	
	rm -v -- "$0" | tee -a "$LOG_FILE"
	printf "\033c" >> /dev/tty1
	msgbox "Updates have been completed.  System will now restart after you hit the A button to continue.  If the system doesn't restart after pressing A, just restart the system manually."
	echo $c_brightness > /sys/class/backlight/backlight/brightness
	sudo reboot
	exit 187
fi




