#!/bin/bash
# -------------------------------------------------------------
# Telramian
# Script to easily install Telraam (https://telraam.net) an rpi
# OS: Raspbian GNU/Linux 10 Lite (Buster) version 2020-02-13
# Python: 3.7.3
# OpenCV: 4.3.0
# Based on https://github.com/Telraam/Telraam-RPi
# Author= Manuel Stevens (manuel.stevens@ardesco.be)
# -------------------------------------------------------------

OPENCV_VERSION='4.3.0'

# path to Telraam application
PATH_TELRAAM=$HOME/Telraam
PATH_TELRAAM_SCRIPTS=$PATH_TELRAAM/Scripts
PATH_TELRAAM_PICTURES=$PATH_TELRAAM/Pictures

# path to Telraam-RPi github clone folder
PATH_TELRAAM_RPI=$PATH_TELRAAM/Telraam-RPi
PATH_TELRAAM_RPI_ACCESS_POINT=$PATH_TELRAAM_RPI/"Access point"
PATH_TELRAAM_RPI_IMAGE_PROCESSING=$PATH_TELRAAM_RPI/"Image processing"
PATH_TELRAAM_RPI_MISC=$PATH_TELRAAM_RPI/Misc
PATH_TELRAAM_RPI_REMOTE_UPDATING=$PATH_TELRAAM_RPI/"Remote updating"

# path to OpenCV
PATH_OPENCV_BASE=$HOME/opencv
PATH_OPENCV=$PATH_OPENCV_BASE/opencv
PATH_OPENCV_CONTRIB=$PATH_OPENCV_BASE/opencv_contrib
PATH_OPENCV_BUILD=$PATH_OPENCV/build

cd $HOME

# This function formats the timestamp
timestamp() { date +"%F_%T_%Z"; }

# This function formats log messages
# echo_process(String message)
echo_process() { echo -e "\\e[1;94m$(timestamp) [Telramian] $*\\e[0m"; }

# Get the timestamp of the install process
timestamp=$(date +%Y%m%d%H%M)

# Log everything to a file
exec &> >(tee -a "telramian-build-$timestamp.log")

echo_process "------------------------------"
echo_process "----Telramian installation----"
echo_process "------------------------------"

echo_process "Setting keyboard to be (Belgian)"
L='be' && sudo sed -i 's/XKBLAYOUT=\"\w*"/XKBLAYOUT=\"'$L'\"/g' /etc/default/keyboard
sudo dpkg-reconfigure keyboard-configuration -f noninteractive
sudo invoke-rc.d keyboard-setup start
sudo setsid sh -c 'exec setupcon -k --force <> /dev/tty1 >&0 2>&1'
sudo udevadm trigger --subsystem-match=input --action=change

echo_process "Disabling splash screen"
CMDLINE=/boot/cmdline.txt
if grep -q "splash" $CMDLINE ; then
    sudo sed -i $CMDLINE -e "s/ quiet//"
    sudo sed -i $CMDLINE -e "s/ splash//"
    sudo sed -i $CMDLINE -e "s/ plymouth.ignore-serial-consoles//"
fi

echo_process "Enabling camera"
sudo tee -a /boot/config.txt > /dev/null <<EOT

start_x=1
gpu_mem=128
EOT

echo_process "Removing unnecessary packages"
sudo apt-get purge samba samba-common-bin -y
sudo apt-get purge wolfram-engine -y
sudo apt-get purge libreoffice* -y
sudo apt-get purge minecraft-pi -y
sudo apt-get remove chromium-browser -y
sudo apt-get remove epiphany-browser -y
sudo apt-get clean -y
sudo apt-get autoremove -y

echo_process "Removing unnecessary folders"
rm -rf ~/MagPi
rm -rf ~/Music
rm -rf ~/Templates
rm -rf ~/Videos

echo_process "Update and upgrade existing packages"
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get clean -y
sudo apt-get autoremove -y

echo_process "Install build tools"
#build-essential: This package contains an informational list of packages which are considered essential for building Debian packages. This package also depends on the packages on that list, to make it easy to have the build-essential packages installed.
#cmake: CMake is an open-source, cross-platform family of tools designed to build, test and package software.
#gcc: The GNU Compiler Collection includes front ends for C, C++, Objective-C, Fortran, Ada, Go, and D, as well as libraries for these languages (libstdc++,...). 
#g++: g++ command is a GNU c++ compiler invocation command, which is used for preprocessing, compilation, assembly and linking of source code to generate an executable file.
#gfortran: GNU Fortran project, developing a free Fortran 95/2003/2008 compiler for GCC, the GNU Compiler Collection.
#pkg-config: computer program that defines and supports a unified interface for querying installed libraries for the purpose of compiling software that depends on them.
#git: Git is a distributed version-control system for tracking changes in source code during software development.
#wget: GNU Wget is a computer program that retrieves content from web servers.
#unzip: unzipping zip compressed files
sudo apt-get install build-essential cmake gcc g++ gfortran pkg-config git wget unzip htop -y

echo_process "Install GTK/GTK+"
#GTK/GTK+ multi-platform toolkit for creating graphical user interfaces. Offering a complete set of widgets, GTK/GTK+ is suitable for projects ranging from small one-off tools to complete application suites.
#This package contains the header and development files which are needed for building GTK/GTK+ applications.
#libgtk2.0-dev GTK+ 
#libgtk-3-dev GTK
sudo apt-get install libgtk2.0-dev libgtk-3-dev -y

echo_process "install Qt (cross-platform C++ application framework)"
#Qt is a cross-platform C++ application framework. Qt's primary feature is its rich set of widgets that provide standard GUI functionality.
#qt5-default: sets Qt 5 to be the default Qt version to be used when using development binaries like qmake. It provides a default configuration for qtchooser, but does not prevent alternative Qt installations from being used.
#libqtgui4: the QtGui module extends QtCore with GUI functionality.
#libqtwebkit4: QtWebKit provides a Web browser engine that makes it easy to embed content from the World Wide Web into your Qt application.
#libqt4-test: Qt 4 test module.
#python3-pyqt5: PyQt5 exposes the Qt5 API to Python 3.
sudo apt-get install qt5-default libqtgui4 libqtwebkit4 libqt4-test python3-pyqt5 -y

echo_process "Install optimizations libraries"
#libatlas-base-dev: Automatically Tuned Linear Algebra Software ATLAS is an approach for the automatic generation and optimization of numerical software. Currently ATLAS supplies optimized versions for the complete set of linear algebra kernels known as the Basic Linear Algebra Subroutines (BLAS), and a subset of the linear algebra routines in the LAPACK library.
#libtbb-dev: TBB development files. TBB is a library that helps you leverage multi-core processor performance without having to be a threading expert. It represents a higher-level, task-based parallelism that abstracts platform details and threading mechanism for performance and scalability. 
#libtbb2: TBB runtime files. TBB is a library that helps you leverage multi-core processor performance without having to be a threading expert. It represents a higher-level, task-based parallelism that abstracts platform details and threading mechanism for performance and scalability.
#libhdf5-dev: Hierarchical Data Format 5 (HDF5) - development files - serial version. HDF5 is a file format and library for storing scientific data. 
#libhdf5-103: Hierarchical Data Format 5 (HDF5) - runtime files - serial version. HDF5 is a file format and library for storing scientific data.
#libeigen3-dev: lightweight C++ template library for linear algebra
#liblapacke-dev: LAPACK version 3.X is a comprehensive FORTRAN library that does linear algebra operations including matrix inversions, least squared solutions to linear sets of equations, eigenvector analysis, singular value decomposition, etc.
#libprotobuf-dev: protocol buffers C++ library 
#protobuf-compiler: compiler for protocol buffer definition files
#libgoogle-glog-dev: library provides logging APIs based on C++-style streams and various helper macros.
#libgflags-dev: library that implements commandline flags processing for C++.
#doxygen: Documentation system for C++, C, Java, Objective-C and IDL.
sudo apt-get install libatlas-base-dev libtbb-dev libtbb2 libhdf5-dev libhdf5-103 libeigen3-dev liblapacke-dev libprotobuf-dev protobuf-compiler libgoogle-glog-dev libgflags-dev doxygen -y

echo_process "install image I/O packages"
#libjpeg-dev: JPEG library.
#libjpeg62-turbo-dev: libjpeg-turbo is a JPEG image codec that uses SIMD instructions (MMX, SSE2, NEON) to accelerate baseline JPEG compression and decompression on x86, x86-64, and ARM systems. 
#libpng-dev: PNG (Portable Network Graphics) library
#libtiff-dev: TIFF (Tag Image File Format) library.
#libjasper-dev: JasPer JPEG-2000 library
#libwebp-dev: webp library (based on the VP8 codec)
#libopenexr-dev: OpenEXR is a high dynamic-range (HDR) image library
sudo apt-get install libjpeg-dev libjpeg62-turbo-dev libpng-dev libtiff-dev libjasper-dev libwebp-dev libopenexr-dev -y 

echo_process "install video I/O packages"
#libavcodec-dev: Libav is a complete, cross-platform solution to decode, encode, record, convert and stream audio and video. This is the codec library from Libav. It supports most existing encoding formats (MPEG, DivX, MPEG4, AC3, DV...). 
#libavformat-dev: Libav is a complete, cross-platform solution to decode, encode, record, convert and stream audio and video. This is the demuxer library from Libav. It supports most existing file formats (AVI, MPEG, OGG, Matroska, ASF...).
#libavresample-dev: Libav is a complete, cross-platform solution to decode, encode, record, convert and stream audio and video. This is the video scaling library from Libav.
#libswscale-dev: FFmpeg is the leading multimedia framework, able to decode, encode, transcode, mux, demux, stream, filter and play pretty much anything that humans and machines have created. It supports the most obscure ancient formats up to the cutting edge. 
#x264: advanced commandline encoder for creating H.264 (MPEG-4 AVC) video streams
#libx264-dev: advanced encoding library for creating H.264 (MPEG-4 AVC) video streams
#libv4l-dev: libv4l is a collection of libraries which adds a thin abstraction layer on top of video4linux2 devices. The purpose of this (thin) layer is to make it easy for application writers to support a wide variety of devices without having to write separate code for different devices in the same class. 
#v4l-utils: Collection of command line video4linux utilities
#libtheora-dev: Theora is a fully open, non-proprietary, patent-and-royalty-free, general-purpose compressed video format.
#libxvidcore-dev: Xvid (formerly XviD) is an open source MPEG-4 video codec, implementing MPEG-4 Simple Profile, Advanced Simple Profile, and Advanced Video Coding standards.
sudo apt-get install libavcodec-dev libavformat-dev libavresample-dev libswscale-dev x264 libx264-dev libv4l-dev v4l-utils libtheora-dev libxvidcore-dev -y

echo_process "install audio I/O packages"
#libmp3lame-dev: LAME (LAME Ain't an MP3 Encoder) includes an MP3 encoding library, a simple frontend application, and other tools for sound analysis, as well as convenience tools.
#libvorbis-dev: development files for Vorbis General Audio Compression Codec. Ogg Vorbis is a fully open, non-proprietary, patent-and-royalty-free, general-purpose compressed audio format for audio and music at fixed and variable bitrates from 16 to 128 kbps/channel.
#libopencore-amrnb-dev: library contains an implementation of the 3GPP TS 26.073 specification for the Adaptive Multi Rate (AMR) speech codec.
sudo apt-get install libmp3lame-dev libvorbis-dev libopencore-amrnb-dev -y

echo_process "install digital camera I/O packages"
#libgphoto2-dev: library can be used by applications to access various digital camera models, via standard protocols such as USB Mass Storage and PTP, or vendor-specific protocols.
sudo apt-get install libgphoto2-dev -y

echo_process "install opencv sub-module highgui (display images, basic GUIs) prerequisites"
#libfontconfig1-dev: Fontconfig is a font configuration and customization library, which does not depend on the X Window System. It is designed to locate fonts within the system and select them according to requirements specified by applications.
#libcairo2-dev: Cairo is a multi-platform 2D library providing anti-aliased vector-based rendering for multiple target backends. This package contains the development libraries, header files needed by programs that want to compile with Cairo.
#libgdk-pixbuf2.0-dev: The GDK Pixbuf library provides Image loading and saving facilities, Fast scaling and compositing of pixbufs and Simple animation loading (ie. animated GIFs). This package contains the header files which are needed for using GDK Pixbuf.
#libpango1.0-dev: Pango is a library for layout and rendering of text, with an emphasis on internationalization. Pango can be used anywhere that text layout is needed. however, most of the work on Pango-1.0 was done using the GTK+ widget toolkit as a test platform. Pango forms the core of text and font handling for GTK+-2.0.
sudo apt-get install libfontconfig1-dev libcairo2-dev libgdk-pixbuf2.0-dev libpango1.0-dev -y

echo_process "Installing python3-dev"
sudo apt-get install python3-dev python3-pip -y

echo_process "Installing python-numpy python-scipy"
sudo apt-get install python-numpy python-scipy -y

echo_process "Update pip and clear cache"
python3 -m pip install --upgrade pip
sudo rm -rf ~/.cache/pip

echo_process "Install testresources picamera[array] wget numpy scipy pandas"
sudo python3 -m pip install testresources picamera[array] wget numpy scipy pandas

echo_process "Increase SWAP space to compile without hanging due to memory exhausting and on all 4 cores"
sudo sed -i 's/CONF_SWAPSIZE=100/CONF_SWAPSIZE=1024/g' /etc/dphys-swapfile
sudo /etc/init.d/dphys-swapfile stop
sudo /etc/init.d/dphys-swapfile start

echo_process "Downloading opencv and opencv_contrib from github"
mkdir -p $PATH_OPENCV_BASE
cd $PATH_OPENCV_BASE
git clone -b $OPENCV_VERSION https://github.com/opencv/opencv.git
cd $PATH_OPENCV
git checkout $OPENCV_VERSION

cd $PATH_OPENCV_BASE
git clone -b $OPENCV_VERSION https://github.com/opencv/opencv_contrib.git
cd $PATH_OPENCV_CONTRIB
git checkout $OPENCV_VERSION

echo_process "Compile and install OpenCV with contrib modules and Python"
mkdir -p $PATH_OPENCV_BUILD >/dev/null 2>&1
cd $PATH_OPENCV_BUILD
cmake -D CMAKE_BUILD_TYPE=RELEASE \
	-D CMAKE_INSTALL_PREFIX=/usr/local \
	-D OPENCV_EXTRA_MODULES_PATH=$PATH_OPENCV_CONTRIB/modules \
	-D BUILD_NEW_PYTHON_SUPPORT=ON \
	-D BUILD_opencv_python3=ON \
	-D HAVE_opencv_python3=ON \
	-D PYTHON_DEFAULT_EXECUTABLE=/usr/bin/python3 \
	-D OPENCV_PYTHON3_INSTALL_PATH=/usr/lib/python3/dist-packages \
	-D OPENCV_ENABLE_NONFREE=ON \
	-D CMAKE_SHARED_LINKER_FLAGS=-latomic \
	-D WITH_TBB=ON \
	-D ENABLE_NEON=ON \
	-D ENABLE_VFPV3=ON \
	-D WITH_V4L=ON \
	-D WITH_QT=ON \
	-D WITH_OPENGL=ON \
	-D BUILD_TESTS=OFF \
	-D INSTALL_C_EXAMPLES=OFF \
	-D INSTALL_PYTHON_EXAMPLES=OFF \
	-D BUILD_EXAMPLES=OFF ..

nproc | xargs -I % make -j%
sudo make install
sudo ldconfig

echo_process "Reset SWAP space to 1000"
sudo sed -i 's/CONF_SWAPSIZE=1024/CONF_SWAPSIZE=100/g' /etc/dphys-swapfile
sudo /etc/init.d/dphys-swapfile stop
sudo /etc/init.d/dphys-swapfile start

echo_process "Instal mysql database server mariadb with python support"
sudo apt-get install mariadb-server python3-mysqldb -y

echo_process "Install apache2 web server with php and mysql support"
sudo apt-get install apache2 php libapache2-mod-php php-mysql -y

echo_process "Install WIFI dnsmasq (dhcp) hostapd (access point)"
sudo apt-get install dnsmasq hostapd -y

echo_process "Install Telraam-RPi master github ripository"
mkdir -p $PATH_TELRAAM
cd $PATH_TELRAAM
git clone https://github.com/Telraam/Telraam-RPi.git
cd $PATH_TELRAAM_RPI
git checkout master

echo_process "Copying files from Telraam-RPi"
mkdir -p $PATH_TELRAAM
mkdir -p $PATH_TELRAAM_SCRIPTS
mkdir -p $PATH_TELRAAM_PICTURES
cp -rf "$PATH_TELRAAM_RPI_ACCESS_POINT"/*.py $PATH_TELRAAM_SCRIPTS
cp -rf "$PATH_TELRAAM_RPI_IMAGE_PROCESSING"/*.py $PATH_TELRAAM_SCRIPTS
cp -rf "$PATH_TELRAAM_RPI_MISC"/*.py $PATH_TELRAAM_SCRIPTS
cp -rf "$PATH_TELRAAM_RPI_REMOTE_UPDATING"/*.py $PATH_TELRAAM_SCRIPTS
chmod +x $PATH_TELRAAM_SCRIPTS/*

#temp fix
# the original telraam script is for opencv 3 while we are using opencv 4
# the difference is that findContours is now returning 2 values instead of 3
# no worries because the 3rd values was not used anayway
# so just replace im2, contours, hierarchy = cv2.findContours with contours, hierarchy = cv2.findContours
# until this is fixed in the original script (pull request submitted)
# change it in telraam_monitoring.py
sed -i 's/im2, contours, hierarchy = cv2.findContours/contours, hierarchy = cv2.findContours/g' $PATH_TELRAAM_SCRIPTS/telraam_monitoring.py
#temp fix

echo_process 'Configuration camera stream (based on https://picamera.readthedocs.io/en/latest/recipes2.html#web-streaming)'
echo_process 'URL for locally testing camera stream http://127.0.0.1:8000/stream.mjpg'
sudo chmod +x $PATH_TELRAAM_SCRIPTS/telraam_camera_stream.py
sudo cp -rf "$PATH_TELRAAM_RPI_ACCESS_POINT"/telraam_camera_stream.service /lib/systemd/system/
sudo chmod 644 /lib/systemd/system/telraam_camera_stream.service
sudo systemctl daemon-reload
sudo systemctl enable telraam_camera_stream.service

echo_process 'Configuration mysql database'
sudo mysql <<MY_QUERY
CREATE DATABASE telraam;
USE telraam;
CREATE TABLE connection(wifi_ssid VARCHAR(32),wifi_pwd VARCHAR(64));
GRANT ALL PRIVILEGES ON *.* TO 'pi'@'localhost' IDENTIFIED BY 'pi';
MY_QUERY

echo_process 'Configuration monitoring script'
sudo chmod +x $PATH_TELRAAM_SCRIPTS/telraam_monitoring.py
sudo cp "$PATH_TELRAAM_RPI_IMAGE_PROCESSING"/telraam_monitoring.service /lib/systemd/system/
sudo chmod 644 /lib/systemd/system/telraam_monitoring.service
sudo systemctl daemon-reload
sudo systemctl enable telraam_monitoring.service

echo_process 'Setup Access Point'
#Change host name from raspberrypi to telraam in host and hostname
sudo sed -i 's/raspberrypi/telraam/g' /etc/hosts
sudo sed -i 's/raspberrypi/telraam/g' /etc/hostname
#settings in files only active after reboot. Set hostname to telraam untill next reboot when files settings activate.
sudo hostname telraam

#Disable ipv6
#in /boot/cmdline.txt, add ipv6.disable=1
sudo tee -a /boot/cmdline.txt > /dev/null <<EOT

ipv6.disable=1
EOT
#in /etc/sysctl.conf, add net.ipv6.conf.all.disable_ipv6=1
sudo tee -a /etc/sysctl.conf > /dev/null <<EOT

net.ipv6.conf.all.disable_ipv6=1
EOT
sudo sysctl -p

#set the country code to BE for wlan0 in /etc/wpa_supplicant/wpa_supplicant.conf 
sudo wpa_cli -i wlan0 set country BE
sudo wpa_cli -i wlan0 save_config

#Unblock WIFI
rfkill unblock wifi

#In order to work as an access point, the Raspberry Pi needs access point (HostAPD) and DHCP server (DNSMasq) software to provide.
#https://www.raspberrypi.org/documentation/configuration/wireless/access-point.md
#Stop dnsmasq and ap hostapd
sudo systemctl stop dnsmasq
sudo systemctl stop hostapd

#set a statict ip address 192.168.254.1 for the access point 
#append to /etc/dhcpcd.conf
sudo tee -a /etc/dhcpcd.conf > /dev/null <<EOT

# TELRAAM
interface wlan0
	static ip_address=192.168.254.1/24
	nohook wpa_supplicant
EOT
#Restart the dhcpcd daemon and set up the new wlan0 configuration
sudo service dhcpcd restart

#The DHCP service is provided by dnsmasq. 
#By default, the configuration file contains a lot of information that is not needed, and it is easier to start from scratch.
#Rename this configuration file /etc/dnsmasq.conf ...
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig

#and create a new one
#For wlan0, we are going to provide IP addresses between 192.168.4.2 and 192.168.4.20, with a lease time of 24 hours.
#If you are providing DHCP services for other network devices (e.g. eth0), you could add more sections with the appropriate interface header, with the range of addresses you intend to provide to that interface.
sudo tee -a /etc/dnsmasq.conf > /dev/null <<EOT

interface=wlan0
dhcp-range=192.168.254.2,192.168.254.254,255.255.255.0,24h
EOT

#Reload dnsmasq to use the updated configuration.
sudo systemctl start dnsmasq
sudo systemctl reload dnsmasq

#You need to edit the hostapd configuration file, located at /etc/hostapd/hostapd.conf, to add the various parameters for your wireless network.
#After initial install, this will be a new/empty file.
#Add the information below to the configuration file.
#This configuration assumes we are using channel 7, with a network name of TELRAAM, and a password TelraamTelraam.
#Note that the name and password should not have quotes around them.
#The passphrase should be between 8 and 64 characters in length.
#To use the 5 GHz band, you can change the operations mode from hw_mode=g to hw_mode=a. Possible values for hw_mode are:
#a = IEEE 802.11a (5 GHz)
#b = IEEE 802.11b (2.4 GHz)
#g = IEEE 802.11g (2.4 GHz)
#ad = IEEE 802.11ad (60 GHz)
sudo tee -a /etc/hostapd/hostapd.conf > /dev/null <<EOT

interface=wlan0
driver=nl80211
ssid=TELRAAM
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=TelraamTelraam
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOT

#We now need to tell the system where to find this configuration file.
#In /etc/default/hostapd, replace the line with #DAEMON_CONF with DAEMON_CONF="/etc/hostapd/hostapd.conf"
sudo sed -i '/#DAEMON_CONF/s/^#//g' /etc/default/hostapd ; sudo sed -i 's/"/&\/etc\/hostapd\/hostapd.conf/1' /etc/default/hostapd

#Enable and start hostapd and reload dnsmasq 
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl start hostapd

#A quick check of their status to ensure they are active and running can be done with commands below:
sudo systemctl status hostapd
sudo systemctl status dnsmasq

#Add routing and masquerade
#In /etc/sysctl.conf, uncomment the line #net.ipv4.ip_forward=1
sudo sed -ir 's/#{1,}?net.ipv4.ip_forward ?= ?(0|1)/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf

#Add a masquerade for outbound traffic on eth0:
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

#Save the iptables rule.
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"

#In /etc/rc.local add 
#sudo ifconfig eth0 down
#iptables-restore < /etc/iptables.ipv4.nat 
##Set random pwd at startup
#echo "pi:$(sudo openssl rand -base64 12 2>&1)" | sudo chpasswd\
#just above "exit 0" to install these rules on boot.
sudo sed -i '/^exit 0/i \\nsudo ifconfig eth0 down\nsudo iptables-restore < /etc/iptables.ipv4.nat\n#Set random pwd at startup\n/bin/echo "pi:$(sudo /usr/bin/openssl rand -base64 12 2>&1)" | sudo /usr/sbin/chpasswd\n' /etc/rc.local

echo_process 'Setup Access Point control'
sudo chmod +x $PATH_TELRAAM_SCRIPTS/telraam_ap_control_loop.py
sudo cp -rf "$PATH_TELRAAM_RPI_ACCESS_POINT"/telraam_ap_control_loop.service /lib/systemd/system/
sudo chmod 644 /lib/systemd/system/telraam_ap_control_loop.service
sudo systemctl daemon-reload
sudo systemctl enable telraam_ap_control_loop.service

echo_process 'Install Login page'
sudo cp -rf "$PATH_TELRAAM_RPI_ACCESS_POINT"/index.php /var/www/html/
sudo chmod 755 /var/www/html/index.php
sudo rm -f /var/www/html/index.html

echo_process 'Setup Remote updating'
sudo chmod +x $PATH_TELRAAM_SCRIPTS/telraam_auto_updater_cron.py
sudo chmod +x $PATH_TELRAAM_SCRIPTS/telraam_remote_updater-monitoring.py
sudo chmod +x $PATH_TELRAAM_SCRIPTS/telraam_remote_updater.py
sudo cp -rf "$PATH_TELRAAM_RPI_REMOTE_UPDATING"/updatecron /etc/cron.d/

echo_process "Augmenting .profile "
sudo tee -a $HOME/.profile > /dev/null <<EOT

export PATH=$PATH:$PATH_TELRAAM_SCRIPTS
alias cls='clear'
alias dir='ls -lh'
alias adir='ls -alh'
alias wdir='ls -h'
alias wadir='ls -ah'
alias del='rm'
alias cd..='cd ..'
alias d='sudo du -h | sort -r -h | less'
alias h='htop'
alias c='sudo raspi-config'
alias u='sudo apt-get update; sudo apt-get upgrade; sudo apt-get autoremove; sudo apt-get clean'
alias ipc='hostname -I'
alias mac='python3 $PATH_TELRAAM_SCRIPTS/telraam_show_mac_address.py'
alias ap='nano $PATH_TELRAAM_SCRIPTS/telraam_ap_control_loop.py'
alias wpa='sudo nano /etc/wpa_supplicant/wpa_supplicant.conf'
alias clearbash='cat /dev/null > ~/.bash_history && history -c && exit'

alias tsysapstatus='sudo systemctl status telraam_ap_control_loop.service | cat'
alias tsysapstart='sudo systemctl start telraam_ap_control_loop.service'
alias tsysapstop='sudo systemctl stop telraam_ap_control_loop.service'
alias tsysaprestart='sudo systemctl restart telraam_ap_control_loop.service'
alias tsysapenable='sudo systemctl enable telraam_ap_control_loop.service'
alias tsysapdisable='sudo systemctl disable telraam_ap_control_loop.service'

alias tsyscamstatus='sudo systemctl status telraam_camera_stream.service | cat'
alias tsyscamstart='sudo systemctl start telraam_camera_stream.service'
alias tsyscamstop='sudo systemctl stop telraam_camera_stream.service'
alias tsyscamrestart='sudo systemctl restart telraam_camera_stream.service'
alias tsyscamenable='sudo systemctl enable telraam_camera_stream.service'
alias tsyscamdisable='sudo systemctl disable telraam_camera_stream.service'

alias tsysmonstatus='sudo systemctl status telraam_monitoring.service | cat'
alias tsysmonstart='sudo systemctl start telraam_monitoring.service'
alias tsysmonstop='sudo systemctl stop telraam_monitoring.service'
alias tsysmonrestart='sudo systemctl restart telraam_monitoring.service'
alias tsysmonenable='sudo systemctl enable telraam_monitoring.service'
alias tsysmondisable='sudo systemctl disable telraam_monitoring.service'
alias tsysmon='sudo python3 $PATH_TELRAAM_SCRIPTS/telraam_monitoring.py --idandtrack --verbose --display; sudo rm -rf test'

alias tsys='cls; tsyscamstatus; tsysapstatus; tsysmonstatus'

alias m='sudo mysql'
EOT
source ~/.profile

echo_process "Augmenting .bashrc "
sudo tee -a $HOME/.bashrc > /dev/null <<EOT

export PATH=$PATH:$PATH_TELRAAM_SCRIPTS
alias cls='clear'
alias dir='ls -lh'
alias adir='ls -alh'
alias wdir='ls -h'
alias wadir='ls -ah'
alias del='rm'
alias cd..='cd ..'
alias d='sudo du -h | sort -r -h | less'
alias h='htop'
alias c='sudo raspi-config'
alias u='sudo apt-get update; sudo apt-get upgrade; sudo apt-get autoremove; sudo apt-get clean'
alias ipc='hostname -I'
alias mac='python3 $PATH_TELRAAM_SCRIPTS/telraam_show_mac_address.py'
alias ap='nano $PATH_TELRAAM_SCRIPTS/telraam_ap_control_loop.py'
alias wpa='sudo nano /etc/wpa_supplicant/wpa_supplicant.conf'
alias clearbash='cat /dev/null > ~/.bash_history && history -c && exit'

alias tsysapstatus='sudo systemctl status telraam_ap_control_loop.service | cat'
alias tsysapstart='sudo systemctl start telraam_ap_control_loop.service'
alias tsysapstop='sudo systemctl stop telraam_ap_control_loop.service'
alias tsysaprestart='sudo systemctl restart telraam_ap_control_loop.service'
alias tsysapenable='sudo systemctl enable telraam_ap_control_loop.service'
alias tsysapdisable='sudo systemctl disable telraam_ap_control_loop.service'

alias tsyscamstatus='sudo systemctl status telraam_camera_stream.service | cat'
alias tsyscamstart='sudo systemctl start telraam_camera_stream.service'
alias tsyscamstop='sudo systemctl stop telraam_camera_stream.service'
alias tsyscamrestart='sudo systemctl restart telraam_camera_stream.service'
alias tsyscamenable='sudo systemctl enable telraam_camera_stream.service'
alias tsyscamdisable='sudo systemctl disable telraam_camera_stream.service'

alias tsysmonstatus='sudo systemctl status telraam_monitoring.service | cat'
alias tsysmonstart='sudo systemctl start telraam_monitoring.service'
alias tsysmonstop='sudo systemctl stop telraam_monitoring.service'
alias tsysmonrestart='sudo systemctl restart telraam_monitoring.service'
alias tsysmonenable='sudo systemctl enable telraam_monitoring.service'
alias tsysmondisable='sudo systemctl disable telraam_monitoring.service'
alias tsysmon='sudo python3 $PATH_TELRAAM_SCRIPTS/telraam_monitoring.py --idandtrack --verbose --display; sudo rm -rf test'

alias tsys='cls; tsyscamstatus; tsysapstatus; tsysmonstatus'

alias m='sudo mysql'
EOT
source ~/.bashrc

echo_process 'Disabling SSH"'
sudo systemctl disable ssh.service
sudo systemctl stop ssh.service

# cleanupo opencv folder
sudo rm -rf $PATH_TELRAAM_RPI
sudo rm -rf $PATH_OPENCV_BASE

echo_process "Log file: telramian-build-$timestamp.log"
echo_process 'Done! You can now reboot with sudo reboot -h now'
