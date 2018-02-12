#!/bin/sh

#Get the path to the script and trim to get the directory.
echo "Setting path to current directory to:"
pathtome=$0
pathtome="${pathtome%/*}"
echo $pathtome

PROJECT_NAME=MLANE

AIR_SDK="/Users/User/sdks/AIR/AIRSDK_28"
echo $AIR_SDK

#Setup the directory.
echo "Making directories."

if [ ! -d "$pathtome/platforms" ]; then
mkdir "$pathtome/platforms"
fi
if [ ! -d "$pathtome/platforms/mac" ]; then
mkdir "$pathtome/platforms/mac"
mkdir "$pathtome/platforms/mac/release"
fi

#Copy SWC into place.
echo "Copying SWC into place."
cp "$pathtome/../bin/$PROJECT_NAME.swc" "$pathtome/"

#Extract contents of SWC.
echo "Extracting files form SWC."
unzip "$pathtome/$PROJECT_NAME.swc" "library.swf" -d "$pathtome"

#Copy library.swf to folders.
echo "Copying library.swf into place."
cp "$pathtome/library.swf" "$pathtome/platforms/mac/release"

FWPATH="$pathtome/../../native_library/mac/$PROJECT_NAME/Build/Products/Release/$PROJECT_NAME.framework/Versions/A/Frameworks"

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

#Copy native libraries into place.
echo "Copying native libraries into place."
cp -R -L "$pathtome/../../native_library/mac/$PROJECT_NAME/Build/Products/Release/$PROJECT_NAME.framework" "$pathtome/platforms/mac/release"


mv "$pathtome/platforms/mac/release/$PROJECT_NAME.framework/Versions/A/Frameworks" "$pathtome/platforms/mac/release/$PROJECT_NAME.framework"
rm -r "$pathtome/platforms/mac/release/$PROJECT_NAME.framework/Versions"

#Run the build command.
echo "Building Release."
"$AIR_SDK"/bin/adt -package \
-target ane "$pathtome/$PROJECT_NAME.ane" "$pathtome/extension_osx.xml" \
-swc "$pathtome/$PROJECT_NAME.swc" \
-platform MacOS-x86-64 -C "$pathtome/platforms/mac/release" "$PROJECT_NAME.framework" "library.swf"

zip "$pathtome/$PROJECT_NAME.ane" -u docs/*


rm -r "$pathtome/platforms/mac"
rm "$pathtome/$PROJECT_NAME.swc"
rm "$pathtome/library.swf"

