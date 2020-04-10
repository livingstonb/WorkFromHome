/* Dataset: ACS */
/* This script generates occupation-industry-specific variables
to be used in correspondence with SHED data. */

clear

local yr1 = 2012
local yr2 = 2017

capture label define bin_lbl 0 "No" 1 "Yes"
capture label define bin_pct_lbl 0 "No" 100 "Yes"

* Collapse by occupation
`#PREREQ' use "build/output/acs_cleaned.dta", clear
drop if missing(sector, soc2d2010)
keep if inrange(year, `yr1', `yr2')

gen wfh2digit = 100 * workfromhome

#delimit ;
collapse
	(mean) wfh2digit
	[iw=perwt], by(soc2d2010) fast;
#delimit cr

gen wfhflex = (wfh2digit > 3.5)
label values wfhflex bin_lbl

`#TARGET' save "stats/output/acs_stats_for_shed.dta", replace