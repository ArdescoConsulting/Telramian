# Telramian
Script to do a headless install of Telraam (https://github.com/Telraam/Telraam-RPi) on a Raspberry Pi

 - OS: Raspberry Pi OS Lite (Buster) version 2020-05-27
 - Python: 3.7.3
 - OpenCV: 4.3.0

The script is based the installation instructions [Misc/general-configuration-HOWTO.txt](https://github.com/Telraam/Telraam-RPi/blob/master/Misc/general-configuration-HOWTO.txt) including the latest security enhancements and latest Raspberry Pi OS and OpenCV version.
# Build instructions
## Install Raspberry Pi OS Lite
Download **Raspberry Pi Imager** from [https://www.raspberrypi.org/downloads/](https://www.raspberrypi.org/downloads/)

Use Raspberry Pi Imager to install the **Raspberry Pi OS Lite* on an SD card.
## Download script
Download **telramian.sh** to the **boot** partition on the sd card.
On Windows this is the only partition you can see and contains files such as cmdline.txt, config.txt,....

If you want to login via ssh instead of the console, create an **empty file** with name  **ssh** in the same folder.
## Create additional user (optional)
For improved security, the password of the pi user is set to a random one at each reboot. Your telraam will work perfectly fine, but you won't be able to log in.

If you want to be able to log in, just create an additional user
`sudo adduser your_login_name`
and give it sudo rightsp
`sudo adduser your_login_name sudo`
## Execute script

Login with user **pi** and password **raspberry**

Set execute permissions for the script

`sudo chmod a+x /boot/telramian.sh`

Execute the script

`/boot/telramian.sh`

The script will take a couple of hours to build (tested in Raspberry Pi 4 4GB)

The output is logged to telramian-build-yyyymmddhhmm.log
# Using telraam
Operating instructions for telraam can be found on https://telraam.net

Enjoy :)
