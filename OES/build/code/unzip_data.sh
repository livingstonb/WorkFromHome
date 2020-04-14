#!/bin/bash

zips=$(find build/input/raw -name "*.zip")
for zip in $zips
do
	unzip -n "$zip" -d "${zip%.*}"
done