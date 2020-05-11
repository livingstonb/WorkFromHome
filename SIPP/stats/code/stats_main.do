
local digits 3 5
local lvls person fam hh

foreach digit of local digits {
foreach lvl of local lvls {
	do "stats/code/compute_occupation_stats.do" `lvl' `digit'
}
}
