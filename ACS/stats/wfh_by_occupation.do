clear
capture log close
log using "$ACSstatstemp/wfh_by_occupation.log", replace

// WFH BY OCCUPATION, THREE DIGIT
cd "$ACSdir"
use "$ACScleaned/acs_cleaned.dta" if inrange(2012, 2018), clear
drop if missing(sector, occ3digit)

label define bin_lbl 0 "No" 1 "Yes", replace
label define bin_pct_lbl 0 "No" 100 "Yes", replace

forvalues yr = 2012/2018 {
	gen wfh_yr`yr' = 100 * workfromhome if (year == `yr')
	label variable wfh_yr`yr' "%WFH, `yr' only"
	label values wfh_yr`yr' bin_pct_lbl
}

* Merge with WFH stats by occupation
// #delimit ;
// merge m:1 occ3digit using "$build/cleaned/occ_group_stats.dta",
// 	keepusing(meanwage_2occ wfhflex3digit) nogen;
// #delimit cr

gen nworkers_unw = 1
label variable nworkers_unw "n, unwtd"

gen nworkers_wt = 1
label variable nworkers_wt "Total workers in group"

gen meanwage = incwage
label variable meanwage "Mean wage/salary income"

* Add blanks
append using "$WFHshared/blanks.dta"
replace blankobs = 0 if missing(blankobs)
replace nworkers_wt = 0 if (blankobs == 1)
replace nworkers_unw = 0 if (blankobs == 1)
label variable blankobs "Empty category"

discard
local title `"Dataset: ACS"'
local title `"`title'"' `"WFH statistics by 3-digit occupation"'
local xlxname "$ACSstatsout/ACS_wfh_by_occ3digit_sector.xlsx"
local sheets `"Sector C"' `"Sector S"'
local descriptions `"Sector C only"' `"Sector S only"'
createxlsx using "`xlxname'", descriptions(`descriptions') sheetnames(`sheets') title(`title')

local snum = 1
forvalues yr = 2012/2018
forvalues sval = 0/1 {
	#delimit ;
	
	local sheetname: word `snum' of `"`sheets'"';

	collapse2excel
		(sum) nworkers_wt
		(rawsum) nworkers_unw
		(mean) wfh_yrs2018
		(mean) meanwage
		(min) blankobs
		[iw=perwt] if (sector == `sval') & (year == `yr')
		using "`xlxname'", by(occ3digit) modify sheet("`sheetname'");
	#delimit cr
	
	local ++snum
}
}
drop nworkers_unw nworkers_wt meanwage
log close
