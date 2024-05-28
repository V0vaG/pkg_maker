#!/bin/bash

user=$SUDO_USER
install_path=/home/vova/my_scripts
#install_path=/usr/local/bin/vova_sphere
log_file='./log'

script_list=($(ls -I pkg_maker.sh -I log -I vova_linker.sh -I vova.sh -I vova_sphere_test.sh -I postinst -I pkgs))
#script_list=(ssh2ec2.sh pass.sh)

for file in "${script_list[@]}"; do
	sed -i "s/abc/$install_path/g" $file
	source $file
	version=$version
	alias=$alias
	echo "Packing: $file version: $version alias: $alias"
	echo "creating dirs for $file"
	mkdir -p "${file%.*}$install_path/${file%.*}"
	cp $file "${file%.*}$install_path/${file%.*}/"
	mkdir -p "${file%.*}/DEBIAN"
	mkdir -p "pkgs"
	echo "
Package: ${file%.*}
Version: $version
Maintainer: Vladimir Glayzer
eMail: its_a_vio@hotmail.com
Architecture: all
Description: ${file%.*}" > "${file%.*}/DEBIAN/control"

	cp postinst "${file%.*}/DEBIAN/postinst"
	#sed -i "s/i_path/$install_path/g" ${file%.*}/DEBIAN/postinst
	sed -i "s/abc_appname/${file%.*}/g" ${file%.*}/DEBIAN/postinst
	sed -i "s/version/$version/g" ${file%.*}/DEBIAN/postinst
	sed -i "s/ALIAS/$alias/g" ${file%.*}/DEBIAN/postinst
	dpkg-deb --build ${file%.*}
	#chmod +x ${file%.*}.deb
	mv ${file%.*}.deb pkgs/
	#rm -r ${file%.*}
done
echo "All dune!!!"
