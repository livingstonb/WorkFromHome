/* --- MAKEFILE INSTRUCTIONS ---
#PREREQ "../ado/createxlsx.ado"
#PREREQ "../ado/collapse2excel.ado"
#PREREQ "../ado/statalist.class"
*/

/* Dataset: ACS */
/* This script computes WFH and other statistics for the ACS.
Statistics are computed separately for different occupations
and sectors. Assumes the cwd is ACS. */

clear
adopath + "../ado"

// WFH BY OCCUPATION, THREE DIGIT
`#PREREQ' local cleaned "build/output/acs_cleaned.dta"
use "`cleaned'" if inrange(year, 2010, 2018), clear
drop if missing(sector)
drop if missing(occ3d2018) & missing(occ3d2010)

label define bin_lbl 0 "No" 1 "Yes", replace
label define bin_pct_lbl 0 "No" 100 "Yes", replace

gen pct_workfromhome = workfromhome * 100
label variable pct_workfromhome "% WFH"

gen nworkers_unw = 1
label variable nworkers_unw "n, unwtd"

gen nworkers_wt = 1
label variable nworkers_wt "Total workers in group"

gen meanwage = incwage
label variable meanwage "Mean wage/salary income"

* Add blanks
tempfile yrtmp
preserve
clear

`#PREREQ' local occ2010 "../occupations/build/output/occindex2010.dta"
save `yrtmp', emptyok
forvalues yr = 2010(1)2017 {
forvalues sval = 0/1 {
	use soc3d2010 using "`occ2010'", clear
	rename soc3d2010 occ3d2010
	gen year = `yr'
	gen sector = `sval'
	gen perwt = 1
	gen blankobs = 1
	
	append using `yrtmp'
	save `yrtmp', replace
}
}
restore
append using `yrtmp'
drop if (occ3d2010 >= 550) & !missing(occ3d2010)

replace blankobs = 0 if missing(blankobs)
replace nworkers_wt = 0 if (blankobs == 1)
replace nworkers_unw = 0 if (blankobs == 1)
label variable blankobs "Empty category"

// PRODUCE STATA FILE
preserve

tempfile acs2017only

#delimit ;
collapse
	(sum) nworkers_wt (rawsum) nworkers_unw
	(mean) pct_workfromhome (mean) meanwage
	(min) blankobs
	[iw=perwt] if (year == 2017), by(occ3d2010 sector) fast;
#delimit cr
gen source = "ACS2017only"
save `acs2017only', replace

restore
preserve

tempfile acs2015to2017

#delimit ;
collapse
	(sum) nworkers_wt (rawsum) nworkers_unw
	(mean) pct_workfromhome (mean) meanwage
	(min) blankobs
	[iw=perwt] if inrange(year, 2015, 2017), by(occ3d2010 sector) fast;
#delimit cr
gen source = "ACS2015to2017"
save `acs2015to2017', replace

restore
preserve

tempfile acs2013to2017

#delimit ;
collapse
	(sum) nworkers_wt (rawsum) nworkers_unw
	(mean) pct_workfromhome (mean) meanwage
	(min) blankobs
	[iw=perwt] if inrange(year, 2013, 2017), by(occ3d2010 sector) fast;
#delimit cr
gen source = "ACS2013to2017"
save `acs2013to2017', replace

clear

use `acs2017only'
append using `acs2015to2017'
append using `acs2013to2017'
`#TARGET' save "stats/output/ACSwfh.dta", replace

restore

// POOLED YEARS
.xlxnotes = .statalist.new
.xlxnotes.append "Dataset: ACS"
.xlxnotes.append "Sample: 2010-2017 pooled"
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
		local conds (sector == `sval') & inrange(year, 2010, 2017)
	}
	else {
		local conds inrange(year, 2010, 2017)
	}
	
	#delimit ;
	collapse2excel
		(sum) nworkers_wt (rawsum) nworkers_unw
		(mean) pct_workfromhome (mean) meanwage
		(min) blankobs
		[iw=perwt] if `conds' using "`pooledxlx'",
		by(occ3d2010) modify sheet("`.sheets.loop_get'");
	#delimit cr
}

// YEARLY
.xlxnotes = .statalist.new
.xlxnotes.append "Dataset: ACS"
.xlxnotes.append "Sample: 2010-2018, separated by year"
.xlxnotes.append "Description: WFH statistics by 3-digit occupation"

`#TARGET' local yearly "stats/output/ACS_wfh_yearly.xlsx"

.descriptions = .statalist.new
forvalues yr = 2010/2018 {
	.descriptions.append "`yr', Sector C"
	.descriptions.append "`yr', Sector S"
	.descriptions.append "`yr', Both sectors"
}
.sheets = .descriptions.copy
createxlsx .descriptions .sheets .xlxnotes using "`yearly'"

.sheets.loop_reset
forvalues yr = 2010/2018 {
	if (`yr' == 2018) {
		local occvar occ3d2018
	}
	else {
		local occvar occ3d2010
	}


forvalues sval = 0/2 {
	.sheets.loop_next
	
	if `sval' < 2 {
		local conds (sector == `sval') & (year == `yr')
	}
	else {
		local conds (year == `yr')
	}
	
	#delimit ;
	collapse2excel
		(sum) nworkers_wt
		(rawsum) nworkers_unw
		(mean) pct_workfromhome
		(mean) meanwage
		[iw=perwt] if `conds'
		using "`yearly'",
		by(`occvar') modify sheet("`.sheets.loop_get'");
	#delimit cr
}
}

drop nworkers_unw nworkers_wt meanwage