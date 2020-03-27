macro drop _all
clear

* Main directory
global maindir "/media/hdd/GitHub/WorkFromHome"

* ATUS
global ATUSdir "$maindir/ATUS"
global ATUSdata "$ATUSdir/data"
global ATUSout "$ATUSdir/output"

capture mkdir "$ATUSout"

* ACS
global ACSdir "$maindir/ACS"
global ACSbuild "$ACSdir/build"
global ACSbuildtemp "$ACSbuild/temp"
global ACScleaned "$ACSbuild/cleaned"
global ACSstats "$ACSdir/stats"
global ACSstatsout "$ACSstats/output"
global ACSstatstemp "$ACSstats/temp"

global ACSallyears 0

capture mkdir "$ACSbuildtemp"
capture mkdir "$ACScleaned"
capture mkdir "$ACSstatsout"
capture mkdir "$ACSstatstemp"

* Other
global WFHshared "$maindir/shared"
adopath + "$maindir/ado"
cd "$maindir"
