macro drop _all
clear

* Main directory
global maindir "/media/hdd/GitHub/WorkFromHome"

* ATUS
global ATUSdir "$maindir/ATUS"
global ATUSbuild "$ATUSdir/build"
global ATUSbuildtemp "$ATUSbuild/temp"
global ATUSstats "$ATUSdir/stats"
global ATUSstatsout "$ATUSstats/output"

capture mkdir "$ATUSbuildtemp"
capture mkdir "$ATUSstatsout"

* ACS
global ACSdir "$maindir/ACS"
global ACSbuild "$ACSdir/build"
global ACSbuildtemp "$ACSbuild/temp"
global ACScleaned "$ACSbuild/cleaned"
global ACSstats "$ACSdir/stats"
global ACSstatsout "$ACSstats/output"
global ACSstatstemp "$ACSstats/temp"

global ACSallyears 1

capture mkdir "$ACSbuildtemp"
capture mkdir "$ACScleaned"
capture mkdir "$ACSstatsout"
capture mkdir "$ACSstatstemp"

* SIPP
global SIPPdir "$maindir/SIPP"
global SIPPbuild "$SIPPdir/build"
global SIPPout "$SIPPdir/output"
global SIPPtemp "$SIPPdir/temp"

capture mkdir "$SIPPout"
capture mkdir "$SIPPtemp"

* OES
global OESdir "$maindir/OES"
global OESbuild "$OESdir/build"
global OESbuildtemp "$OESbuild/temp"
global OESout "$OESbuild/output"

capture mkdir "$OESbuildtemp"
capture mkdir "$OESout"

* Dingel-Neiman
global DNdir "$maindir/DingelNeiman"
global DNbuild "$DNdir/build"
global DNbuildtemp "$DNbuild/temp"
global DNout "$DNbuild/output"

capture mkdir "$DNbuildtemp"
capture mkdir "$DNout"

* SHED
global SHEDdir "$maindir/SHED"
global SHEDbuild "$SHEDdir/build"
global SHEDbuildtemp "$SHEDbuild/temp"
global SHEDout "$SHEDbuild/output"

capture mkdir "$SHEDbuildtemp"
capture mkdir "$SHEDout"

* Other
global WFHshared "$maindir/shared"
adopath + "$WFHshared/ado"
cd "$maindir"
