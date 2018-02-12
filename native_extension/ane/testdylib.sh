#!/bin/sh
#

FWPATH="/Users/User/flash/ML-ANE/native_library/mac/MLANE/Build/Products/Release/MLANE.framework/Versions/A/Frameworks"

if [ -f "$FWPATH/libswiftAppKit.dylib" ]; then
rm "$FWPATH/libswiftAppKit.dylib"
fi
if [ -f "$FWPATH/libswiftCore.dylib" ]; then
rm "$FWPATH/libswiftCore.dylib"
fi
if [ -f "$FWPATH/libswiftCoreData.dylib" ]; then
rm "$FWPATH/libswiftCoreData.dylib"
fi
if [ -f "$FWPATH/libswiftCoreFoundation.dylib" ]; then
rm "$FWPATH/libswiftCoreFoundation.dylib"
fi
if [ -f "$FWPATH/libswiftCoreGraphics.dylib" ]; then
rm "$FWPATH/libswiftCoreGraphics.dylib"
fi
if [ -f "$FWPATH/libswiftCoreImage.dylib" ]; then
rm "$FWPATH/libswiftCoreImage.dylib"
fi
if [ -f "$FWPATH/libswiftDarwin.dylib" ]; then
rm "$FWPATH/libswiftDarwin.dylib"
fi
if [ -f "$FWPATH/libswiftDispatch.dylib" ]; then
rm "$FWPATH/libswiftDispatch.dylib"
fi
if [ -f "$FWPATH/libswiftFoundation.dylib" ]; then
rm "$FWPATH/libswiftFoundation.dylib"
fi
if [ -f "$FWPATH/libswiftIOKit.dylib" ]; then
rm "$FWPATH/libswiftIOKit.dylib"
fi
if [ -f "$FWPATH/libswiftMetal.dylib" ]; then
rm "$FWPATH/libswiftMetal.dylib"
fi
if [ -f "$FWPATH/libswiftObjectiveC.dylib" ]; then
rm "$FWPATH/libswiftObjectiveC.dylib"
fi
if [ -f "$FWPATH/libswiftos.dylib" ]; then
rm "$FWPATH/libswiftos.dylib"
fi
if [ -f "$FWPATH/libswiftQuartzCore.dylib" ]; then
rm "$FWPATH/libswiftQuartzCore.dylib"
fi
if [ -f "$FWPATH/libswiftXPC.dylib" ]; then
rm "$FWPATH/libswiftXPC.dylib"
fi
