# Telramian
Script to do a headless install of Telraam (https://telraam.net) on a Raspberry Pi
OS: Raspbian GNU/Linux 10 Lite (Buster)
Python: 3.7.3
OpenCV: 4.1.2.
Based on https://github.com/Telraam/Telraam-RPi
Author: Manuel Stevens (manuel.stevens@ardesco.be)

The script is a headless version of the installation instructions 
[Misc/general-configuration-HOWTO.txt](https://github.com/Telraam/Telraam-RPi/blob/master/Misc/general-configuration-HOWTO.txt)

##Installation procedure

Download the latest Raspian Buster Lite from

`<link>` https://downloads.raspberrypi.org/raspbian_lite_latest

Put the image on an SD card (minimum 32Gb for build) with Etcher

`<link>` https://www.balena.io/etcher/

Create an empty file ssh on the root partition of the SD card

Boot the Pi with the SDCard

SSH to the pi with username pi and password raspbian

Copy the file telramian.sh to the home directory

Set permissions

`$ chmod a+x telramian.sh`

Execute the script

`./telramian.sh`

The script will take a couple of hours to build (tested in Raspberry Pi 4 4GB)

The output is logged to telramian-build-yyyymmddhhmm.log

Follow further instructions on how to use it can be found on on 

`<link>` https://telraam.net

Enjoy :)

