#!/bin/sh

AneVersion="1.3.0"
FreSwiftVersion="4.4.0"

wget -O ../native_extension/ane/FreSwift.ane https://github.com/tuarua/Swift-IOS-ANE/releases/download/$FreSwiftVersion/FreSwift.ane?raw=true
wget -O ../native_extension/ane/MLANE.ane https://github.com/tuarua/ML-ANE/releases/download/$AneVersion/MLANE.ane?raw=true
