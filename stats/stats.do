clear

global stats "$maindir/stats"
global statsout "$stats/output"
capture mkdir "$statsout"


do "$stats/wfh_by_subgroup.do"
do "$stats/summary_stats.do"