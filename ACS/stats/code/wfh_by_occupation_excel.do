/* --- HEADER ---
This script computes WFH and other statistics for the ACS.
Statistics are computed separately for different occupations
and sectors. Assumes the cwd is ACS.
*/

clear
adopath + "../ado"

// WFH BY OCCUPATION, THREE DIGIT
`#PREREQ' local cleaned "build/output/acs_cleaned.dta"
use "`cleaned'" if inrange(year, 2013, 2017), clear
drop if missing(sector, occ3d2010)

capture label define bin_lbl 0 "No" 1 "Yes"
capture label define bin_pct_lbl 0 "No" 100 "Yes"

gen nworkers_wt = 1

* Add blanks
`#PREREQ' local blanks "../occupations/build/output/soc3dvalues2010.dta"

#delimit ;
appendblanks soc3d2010 using "`blanks'",
	zeros(nworkers_wt nworkers_unw) ones(perwt)
	over1(sector) values1(0 1) over2(year)
	values2(2013 2014 2015 2016 2017)
	rename(occ3d2010);
#delimit cr

* Collapse variables
#delimit ;
.incwage = .collapsevar.new incwage,
	cmd(mean) colname("Mean wage/salary income");
.pct_workfromhome = .collapsevar.new pct_workfromhome,
	cmd(mean) counts colname("% WFH");
.nworkers_wt = .collapsevar.new nworkers_wt,
	cmd(sum) colname("Total workers in group");
.blankobs = .collapsevar.new blankobs,
	cmd(min) colname("Empty category");
.occ3d2010 = .collapsevar.new occ3d2010,
	colname("Occupation");
#delimit cr

* Local containing collapse variables
local cvars .nworkers_wt .pct_workfromhome .incwage .blankobs

// POOLED YEARS
.xlxnotes = .statalist.new
.xlxnotes.append "Dataset: ACS"
.xlxnotes.append "Sample: 2013-2017 pooled"
.xlxnotes.append "Description: WFH statistics by 3-digit occupation"

`#TARGET' local pooledxlx "stats/output/ACS_wfh_pooled.xlsx"

.descriptions = .statalist.new
.descriptions.append "Sector S"
.descriptions.append "Sector C"
.descriptions.append "Both sectors"
.sheets = .descriptions.copy

#delimit ;
createxlsx .descriptions .sheets .xlxnotes
	using "`pooledxlx'";
#delimit cr

.sheets.loop_reset
forvalues sval = 0/2 {
	.sheets.loop_next
	
	if `sval' < 2 {
		local conds (sector == `sval') & inrange(year, 2013, 2017)
	}
	else {
		local conds inrange(year, 2013, 2017)
	}

	#delimit ;
	collapsecustom `cvars' [iw=perwt] if `conds'
		using "`pooledxlx'", by(.occ3d2010)
		modify sheet("`.sheets.loop_get'");
	#delimit cr
}

// YEARLY
.xlxnotes = .statalist.new
.xlxnotes.append "Dataset: ACS"
.xlxnotes.append "Sample: 2013-2017, separated by year"
.xlxnotes.append "Description: WFH statistics by 3-digit occupation"

`#TARGET' local yearly "stats/output/ACS_wfh_yearly.xlsx"

.descriptions = .statalist.new
forvalues yr = 2013/2017 {
	.descriptions.append "`yr', Sector C"
	.descriptions.append "`yr', Sector S"
	.descriptions.append "`yr', Both sectors"
}
.sheets = .descriptions.copy
createxlsx .descriptions .sheets .xlxnotes using "`yearly'"

.sheets.loop_reset
forvalues yr = 2013/2017 {
forvalues sval = 0/2 {
	.sheets.loop_next
	
	if `sval' < 2 {
		local conds (sector == `sval') & (year == `yr')
	}
	else {
		local conds (year == `yr')
	}

	#delimit ;
	collapsecustom `cvars' [iw=perwt] if `conds'
		using "`yearly'", by(.occ3d2010)
		modify sheet("`.sheets.loop_get'");
	#delimit cr
}
}
