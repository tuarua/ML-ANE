#!/bin/sh

rm -r tvos_dependencies/device
rm -r tvos_dependencies/simulator

wget https://github.com/tuarua/Swift-IOS-ANE/releases/download/2.3.0/tvos_dependencies.zip
unzip -u -o tvos_dependencies.zip
rm tvos_dependencies.zip

wget https://github.com/tuarua/ML-ANE/releases/download/0.0.5/tvos_dependencies.zip
unzip -u -o tvos_dependencies.zip
rm tvos_dependencies.zip

wget -O ../native_extension/ane/MLANE.ane https://github.com/tuarua/ML-ANE/releases/download/0.0.5/MLANE.ane?raw=true
