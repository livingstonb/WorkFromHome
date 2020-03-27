macro drop _all

global maindir "/media/hdd/GitHub/WorkFromHome"
global ATUSdir "$maindir/ATUS"
global ATUSdata "$ATUSdir/data"
global ATUSout "$ATUSdir/output"

capture mkdir "$ATUSout"
adopath + "$maindir/ado"

cd "$ATUSdir"
