#!/bin/bash
echo "--------------------------------------------------------------------"
echo "This script installs necessary packages, compiles and install Silice"
echo "Please refer to the script source code to see the list of packages"
echo "--------------------------------------------------------------------"
echo "     >>>> it will request sudo access to install packages <<<<"
echo "--------------------------------------------------------------------"

read -p "Please type 'y' to go ahead, any other key to exit: " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
	echo
	echo "Exiting."
	exit
fi
echo ""

# -------------- install packages ----------------------------
# attempt to guess
source /etc/os-release
if [ "$ID" == "arch"  ]; then
  sudo ./install_dependencies_archlinux.sh
else
	if [ "$ID" == "fedora"  ]; then
		sudo ./install_dependencies_fedora.sh
	else
		if [ "$ID" == "debian"  ] || [ "$ID_LIKE" == "debian"  ]; then
			sudo ./install_dependencies_debian_like.sh
		else
			echo "Cannot determine Linux distrib to install dependencies\n(if this fails please run the install_dependencies script that matches your distrib)."
		fi
	fi
fi

# -------------- retrieve oss-cad-suite package --------------
OSS_CAD_MONTH=07
OSS_CAD_DAY=03
OSS_CAD_YEAR=2025
OSS_PACKAGE=oss-cad-suite-linux-x64-$OSS_CAD_YEAR$OSS_CAD_MONTH$OSS_CAD_DAY.tgz

rm -rf tools/fpga-binutils/
rm -rf tools/oss-cad-suite/
sudo rm -rf /usr/local/share/silice
wget -c https://github.com/YosysHQ/oss-cad-suite-build/releases/download/$OSS_CAD_YEAR-$OSS_CAD_MONTH-$OSS_CAD_DAY/$OSS_PACKAGE
sudo mkdir -p /usr/local/share/silice
sudo mv $OSS_PACKAGE /usr/local/share/silice/
sudo cp tools/oss-cad-suite-env.sh /usr/local/share/silice/
cd /usr/local/share/silice ; sudo tar xvfz ./$OSS_PACKAGE ; sudo rm ./$OSS_PACKAGE ; cd -

# -------------- compile Silice -----------------------------
./compile_silice_linux.sh

# -------------- add path to .bashrc ------------------------
DIR=`pwd`
echo 'source /usr/local/share/silice/oss-cad-suite-env.sh' >> ~/.bashrc

echo ""
echo "--------------------------------------------------------------------"
echo "Please start a new shell before using Silice (PATH has been changed)"
echo "--------------------------------------------------------------------"
