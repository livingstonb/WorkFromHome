clear

global stats "$maindir/stats"
global statsout "$stats/output"
capture mkdir "$statsout"

do "$stats/preliminary_computations.do"
do "$stats/subgroup_statistics.do"

* do "$stats/wfh_by_subgroup.do"
* do "$stats/summary_stats.do"
