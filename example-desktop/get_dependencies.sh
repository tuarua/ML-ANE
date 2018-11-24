#!/bin/sh

AneVersion="0.1.0"
FreSwiftVersion="2.5.0"

wget -O ../native_extension/ane/CommonDependencies.ane https://github.com/tuarua/Swift-IOS-ANE/releases/download/$FreSwiftVersion/CommonDependencies.ane?raw=true
wget -O ../native_extension/ane/MLANE.ane https://github.com/tuarua/ML-ANE/releases/download/$AneVersion/MLANE.ane?raw=true
