#!/bin/bash
clear
UPDATE_DATE="10252024"
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


if [ ! -f "/home/ark/.config/.update09272024" ]; then

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
	
	touch "/home/ark/.config/.update09272024"

fi

if [ ! -f "/home/ark/.config/.update09292024" ]; then

	printf "\nFix SDL 2.30.7 builtin joystick detection issue\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/09292024/arkosupdate09292024.zip -O /dev/shm/arkosupdate09292024.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate09292024.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate09292024.zip" ]; then
	  sudo unzip -X -o /dev/shm/arkosupdate09292024.zip -x home/ark/ogage-gameforce-chi -d / | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate09292024.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate09292024.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
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
	  sudo chmod -R 755 /opt/system/Advanced/ | tee -a "$LOG_FILE"
	  sudo chmod -R 755 /opt/system/DeviceType/ | tee -a "$LOG_FILE"
	  sudo chown -Rv  ark:ark /opt/system/DeviceType/ | tee -a "$LOG_FILE"
		
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)(AeUX)" /usr/share/plymouth/themes/text.plymouth
	touch "/home/ark/.config/.update09292024"

fi
	
if [ ! -f "$UPDATE_DONE" ]; then

	printf "\nUpdate emulationstation to exclude menu.scummvm from scraping\nUpdate DS4 Controller config for retroarches\nUpdate Hypseus-Singe to 2.11.3\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/10252024/arkosupdate10252024.zip -O /dev/shm/arkosupdate10252024.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate10252024.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate10252024.zip" ]; then
	  sudo unzip -X -o /dev/shm/arkosupdate10252024.zip -d / | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate10252024.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate10252024.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	printf "\nCopy correct Hypseus-Singe for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
      rm -fv /opt/hypseus-singe/hypseus-singe.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/hypseus-singe/hypseus-singe.rk3326 /opt/hypseus-singe/hypseus-singe | tee -a "$LOG_FILE"
	fi


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




