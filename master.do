
clear
global maindir "/media/hdd/GitHub/WorkFromHome"
global build "$maindir/build"
global stats "$maindir/stats"
global occ_ind_breakdown

cd "$maindir"

do "$build/read.do"

do "$build/gen_variables.do"
do "$stats/stats.do"
