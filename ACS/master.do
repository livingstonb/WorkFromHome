
clear
global maindir "/media/hdd/GitHub/WorkFromHome/ACS"
global build "$maindir/build"
global stats "$maindir/stats"
global allyears 0

adopath + "/media/hdd/GitHub/WorkFromHome/ado"

cd "$maindir"

do "$build/read.do"

do "$build/gen_variables.do"
do "$stats/stats.do"
