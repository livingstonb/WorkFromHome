
clear
global maindir "/media/hdd/GitHub/WorkFromHome"
global build "$maindir/build"
global stats "$maindir/stats"
global allyears 0

cd "$maindir"

do "$build/read.do"

do "$build/gen_variables.do"
do "$stats/stats.do"
