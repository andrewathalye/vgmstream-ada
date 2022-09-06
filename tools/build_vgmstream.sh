#!/bin/sh
if [ ! -d ext_src ]
then
	wget https://github.com/vgmstream/vgmstream/archive/refs/tags/r1721.tar.gz
	tar xf r1721.tar.gz || exit 1
	mv vgmstream-r1721 ext_src
	patch ext_src/src/meta/ktac.c patches/ktac.c.patch
	rm r1721.tar.gz
fi

if [ ! -f ext_lib/libvgmstream.so ] && [ ! -f ext_lib/libvgmstream.dll ]
then
	if [ ! -d ext_lib ]
	then
		mkdir ext_lib
	fi;

	cd ext_src
	mkdir build
	cd build
	cmake .. -D BUILD_AUDACIOUS=OFF -D BUILD_CLI=OFF -D BUILD_V123=OFF -D USE_ATRAC9=OFF  -D USE_CELT=OFF -D USE_FFMPEG=OFF -D USE_G719=OFF -D USE_G7221=OFF -D USE_JANSSON=OFF -D USE_MAIATRAC3PLUS=OFF -D USE_MPEG=OFF -D USE_SPEEX=OFF -G Ninja || exit 1
	case "$OS" in
		"Windows_NT")
			ninja libvgmstream.dll || exit 1
			mv src/libvgmstream.dll ../../ext_lib/
			;;
		*)
			ninja libvgmstream.so || exit 1
			mv src/libvgmstream.so ../../ext_lib/
			;;
	esac
	cd ../..
	echo "Done building"
else
	echo "Already built, skipping."
fi
