#!/bin/bash
clear
UPDATE_DATE="12242024"
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
	
if [ ! -f "/home/ark/.config/.update10252024" ]; then

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
	touch "/home/ark/.config/.update10252024"
fi

if [ ! -f "/home/ark/.config/.update11272024" ]; then

	printf "\nUpdate GZDoom to 4.13.1\nUpdate PPSSPP to 1.18.1\nUpdated Mupen64plus standalone\nUpdate XRoar to 1.7.1\nFix ScummVM single sd card setup\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/11272024/arkosupdate11272024.zip -O /dev/shm/arkosupdate11272024.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate11272024.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate11272024.zip" ]; then
	  sudo unzip -X -o /dev/shm/arkosupdate11272024.zip -d / | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate11272024.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate11272024.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	printf "\nCopy correct gzdoom depending on device\n" | tee -a "$LOG_FILE"
	  cp -fv /opt/gzdoom/gzdoom.rk3326 /opt/gzdoom/gzdoom | tee -a "$LOG_FILE"
	  sudo rm -fv /opt/gzdoom/gzdoom.* | tee -a "$LOG_FILE"

	printf "\nCopy correct mupen64plus standalone for the chipset\n" | tee -a "$LOG_FILE"
	  cp -fv /opt/mupen64plus/mupen64plus-video-GLideN64.so.rk3326 /opt/mupen64plus/mupen64plus-video-GLideN64.so | tee -a "$LOG_FILE"
	  cp -fv /opt/mupen64plus/mupen64plus-video-glide64mk2.so.rk3326 /opt/mupen64plus/mupen64plus-video-glide64mk2.so | tee -a "$LOG_FILE"
	  cp -fv /opt/mupen64plus/mupen64plus-video-rice.so.rk3326 /opt/mupen64plus/mupen64plus-video-rice.so | tee -a "$LOG_FILE"
	  cp -fv /opt/mupen64plus/mupen64plus-audio-sdl.so.rk3326 /opt/mupen64plus/mupen64plus-audio-sdl.so | tee -a "$LOG_FILE"
	  cp -fv /opt/mupen64plus/mupen64plus.rk3326 /opt/mupen64plus/mupen64plus | tee -a "$LOG_FILE"
	  cp -fv /opt/mupen64plus/libmupen64plus.so.2.0.0.rk3326 /opt/mupen64plus/libmupen64plus.so.2.0.0 | tee -a "$LOG_FILE"
	  cp -fv /opt/mupen64plus/mupen64plus-rsp-hle.so.rk3326 /opt/mupen64plus/mupen64plus-rsp-hle.so | tee -a "$LOG_FILE"
	  cp -fv /opt/mupen64plus/mupen64plus-input-sdl.so.rk3326 /opt/mupen64plus/mupen64plus-input-sdl.so | tee -a "$LOG_FILE"
	  rm -fv /opt/mupen64plus/*.rk3326 | tee -a "$LOG_FILE"
	  
	printf "\nCopy correct PPSSPPSDL for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
      rm -fv /opt/ppsspp/PPSSPPSDL.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/ppsspp/PPSSPPSDL.rk3326 /opt/ppsspp/PPSSPPSDL | tee -a "$LOG_FILE"
	fi


	if [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ]; then
	  printf "\nFix ScummVM saving issue for Single card SD setup\n" | tee -a "$LOG_FILE"
	  sed -i '/roms2\//s//roms\//g' /home/ark/.config/scummvm/scummvm.ini
	fi

	if [ ! -f "/boot/rk3566.dtb" ] && [ ! -f "/boot/rk3566-OC.dtb" ]; then
	  if test -z "$(cat /boot/boot.ini | grep 'vt.global_cursor_default')"
	  then
	    printf "\nDisabling blinking cursor when entering and exiting Emulationstation\n" | tee -a "$LOG_FILE"
		sudo sed -i '/consoleblank\=0/s//consoleblank\=0 vt.global_cursor_default\=0/g' /boot/boot.ini
	  fi
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)(AeUX)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update11272024"
fi

	if [ ! -f "$UPDATE_DONE" ]; then

	printf "\nUpdate ScummVM to 2.9.0\nUpdate SDL to 2.30.10\nUpdate Change Ports SDL tool\nUpdate Filebrowser to 2.31.2\nUpdate enable_vibration script\nUpdate daphne.sh and single.sh scripts for RGB30 Unit\nAdd j2me to nes-box and sagabox themes\nUpdate coco.sh to accomodate alternate default controls\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/12242024/arkosupdate12242024.zip -O /dev/shm/arkosupdate12242024.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate12242024.zip | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/12242024/arkosupdate12242024.z01 -O /dev/shm/arkosupdate12242024.z01 -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate12242024.z01 | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate12242024.zip" ] && [ -f "/dev/shm/arkosupdate12242024.z01" ]; then
	  zip -FF /dev/shm/arkosupdate12242024.zip --out /dev/shm/arkosupdate.zip -fz | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate12242024.z* | tee -a "$LOG_FILE"
	  if test ! -z $(tr -d '\0' < /proc/device-tree/compatible | grep rk3566)
	  then
	    if [ ! -z "$(grep "RGB30" /home/ark/.config/.DEVICE | tr -d '\0')" ]; then
	      sudo unzip -X -o /dev/shm/arkosupdate.zip -x home/ark/sd_fuse/* roms/themes/es-theme-nes-box/* -d / | tee -a "$LOG_FILE"
		else
	      sudo unzip -X -o /dev/shm/arkosupdate.zip -x home/ark/sd_fuse/* roms/themes/es-theme-sagabox/* -d / | tee -a "$LOG_FILE"
		fi
	  else
	    sudo unzip -X -o /dev/shm/arkosupdate.zip -x usr/local/bin/enable_vibration.sh roms/themes/es-theme-sagabox/* -d / | tee -a "$LOG_FILE"
	  fi
	  sudo rm -fv /home/ark/add_j2me.txt | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate12242024.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	printf "\nInstall and link new SDL 2.0.3000.10 (aka SDL 2.0.30.10)\n" | tee -a "$LOG_FILE"
	  sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.3000.10.rk3326 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.10 | tee -a "$LOG_FILE"
	  sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.3000.10.rk3326 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.10 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.10 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.10 /usr/lib/arm-linux-gnueabihf/libSDL2.so | tee -a "$LOG_FILE"

	  sudo rm -fv /opt/system/DeviceType/R33S.sh | tee -a "$LOG_FILE"
	  sudo chmod -R +x /opt/system/*

	printf "\nCopy correct scummvm for device\n" | tee -a "$LOG_FILE"

      mv -fv /opt/scummvm/scummvm.rk3326 /opt/scummvm/scummvm | tee -a "$LOG_FILE"


	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ] || [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-r33s-linux.dtb" ] || [ -f "/boot/rk3326-r35s-linux.dtb" ] || [ -f "/boot/rk3326-r36s-linux.dtb" ]; then
	  printf "\nFixing fail booting when second sd card is not found or not in the expected format.\n" | tee -a "$LOG_FILE"
	  if [ -f "/opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh" ]; then
		sudo chown -R ark:ark /opt
	    sed -i '/noatime,uid\=1002/s//noatime,nofail,x-systemd.device-timeout\=7,uid\=1002/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
	    sed -i '/defaults 0 1/s//defaults,nofail,x-systemd.device-timeout\=7 0 1/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
	    sudo sed -i '/none bind/s//none nofail,x-systemd.device-timeout\=7,bind/' /etc/fstab
	  else
        sudo sed -i '/noatime,uid\=1002/s//noatime,nofail,x-systemd.device-timeout\=7,uid\=1002/' /etc/fstab
	    sudo sed -i '/defaults 0 1/s//defaults,nofail,x-systemd.device-timeout\=7 0 1/' /etc/fstab
	    sudo sed -i '/none bind/s//none nofail,x-systemd.device-timeout\=7,bind/' /etc/fstab
	    sudo systemctl daemon-reload && sudo systemctl restart local-fs.target
	  fi
	  sudo sed -i '/noatime,uid\=1002/s//noatime,nofail,x-systemd.device-timeout\=7,uid\=1002/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
	  sudo sed -i '/defaults 0 1/s//defaults,nofail,x-systemd.device-timeout\=7 0 1/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
	  printf "  Done.\n" | tee -a "$LOG_FILE"
	fi

	  printf "\nThis is not an oga1.1/rgb10/v10 unit.  No uboot flash needed.\n" | tee -a "$LOG_FILE"
	  if [ -d "/home/ark/sd_fuse" ]; then
	    rm -rfv /home/ark/sd_fuse | tee -a "$LOG_FILE"
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




