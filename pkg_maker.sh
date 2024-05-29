#!/bin/bash

#https://earthly.dev/blog/creating-and-hosting-your-own-deb-packages-and-apt-repo/
#sudo apt-get install -y gcc dpkg-dev gpg

user=$SUDO_USER
install_path=usr/bin
log_file='./log'
architecture='amd64'

script_list=($(ls -I pkg_maker.sh -I log -I vova_linker.sh -I vova.sh -I vova_sphere_test.sh -I generate-release.sh -I apt-repo))

#script_list=(ssh2ec2.sh)


mkdir -p ./apt-repo/pool/main/
mkdir -p ./apt-repo/dists/stable/main/binary-amd64

for file in "${script_list[@]}"; do
	sed -i "s/abc/$install_path/g" $file
	source $file
	version=$version
	alias=$alias
	echo "Packing: $file version: $version alias: $alias"
	echo "creating dirs for $file"
	mkdir -p "${file%.*}_${version}_$architecture/$install_path"
	cp -p $file "${file%.*}_${version}_$architecture/$install_path/$alias"
	mkdir -p "${file%.*}_${version}_$architecture/DEBIAN"

	echo "Package: ${file%.*}
Version: $version
Architecture: amd64
Maintainer: Vladimir Glayzer
Homepage: http://example.com
eMail: its_a_vio@hotmail.com
Description: ${file%.*}" > "${file%.*}_${version}_$architecture/DEBIAN/control"

	echo "chmod 777 /$install_path/$alias" > "${file%.*}_${version}_$architecture/DEBIAN/postinst"
	
	chmod 775 "${file%.*}_${version}_$architecture/DEBIAN/postinst"

	dpkg --build ./${file%.*}_${version}_$architecture
	
	mv "${file%.*}_${version}_$architecture.deb" "./apt-repo/pool/main/${file%.*}_${version}_$architecture.deb"

	rm -r ${file%.*}_${version}_$architecture
done

cd apt-repo && dpkg-scanpackages --arch amd64 pool/ > dists/stable/main/binary-amd64/Packages

cat dists/stable/main/binary-amd64/Packages | gzip -9 > dists/stable/main/binary-amd64/Packages.gz

#cd /apt-repo/dists/stable/
#/home/vova/Desktop/vova_sphere_v4/generate-release.sh > Release

#echo "deb [arch=amd64] http://127.0.0.1:8000/apt-repo stable main" | sudo tee /etc/apt/sources.list.d/vova_repo.list

#cd ~/GIT/vova_repo
#python3 -m http.server

#sudo apt-get install -f *.deb
