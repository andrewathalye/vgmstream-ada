VGMStream-Ada
=============

Ada Bindings for VGMStream. Some extra convenience features, like WAV export, are included to make integration easier.

Building
--------

Run `./tools/build_vgmstream.sh` to download and build VGMStream.  
On \*nix, libvorbis is required. On Windows, make sure to use MinGW x64 or MSYS.

Run `gprbuild -Pvgmstream` to build the Ada bindings for this project, or `with` the GPR file in your own project.  

N.B. On Windows you may need to copy libvgmstream.dll to the same folder as your application for it to launch correctly.  
