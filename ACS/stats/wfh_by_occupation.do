clear
capture log close
log using "$ACSstatstemp/wfh_by_occupation.log", replace

// WFH BY OCCUPATION, THREE DIGIT
cd "$ACSdir"
use "$ACScleaned/acs_cleaned.dta" if inrange(year, 2012, 2018), clear
drop if missing(sector)
drop if missing(occ3d2018) & missing(occ3d2010)

label define bin_lbl 0 "No" 1 "Yes", replace
label define bin_pct_lbl 0 "No" 100 "Yes", replace

gen pct_workfromhome = workfromhome * 100
label variable pct_workfromhome "% WFH"

// forvalues yr = 2012/2018 {
// 	gen wfh_yr`yr' = 100 * workfromhome if (year == `yr')
// 	label variable wfh_yr`yr' "%WFH, `yr' only"
// 	label values wfh_yr`yr' bin_pct_lbl
// }

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
tempfile yrtmp
forvalues yr = 2018/2018 {
forvalues sval = 0/1 {
	preserve
	
	if (`yr' == 2018) {
		local occyear 2018
	}
	else {
		local occyear 2010
	}
	use if occyear == `occyear' using "$WFHshared/occblanks.dta", clear
	gen year = `yr'
	gen sector = `sval'

	drop occyear
	drop normwt
	
	save `yrtmp', replace
	restore
	
	append using `yrtmp'
}
}
replace blankobs = 0 if missing(blankobs)
replace nworkers_wt = 0 if (blankobs == 1)
replace nworkers_unw = 0 if (blankobs == 1)

discard
// .title = .statavec
local title `"Dataset: ACS"'
local title `"`title'"' `"WFH statistics by 3-digit occupation"'
local xlxname "$ACSstatsout/ACS_wfh_by_occ3digit_sector.xlsx"

.descriptions = .statalist.new
forvalues yr = 2018/2018 {
	.descriptions.append "`yr', Sector C"
	.descriptions.append "`yr', Sector S"
}
.sheets = .descriptions.copy
sl_createxlsx .descriptions .sheets using "`xlxname'", title(`title')

.sheets.loop_reset
local i = 1
forvalues yr = 2018/2018 {
	if (`yr' == 2018) {
		local occvar occ3d2018
	}
	else {
		local occvar occ3d2010
	}


forvalues sval = 0/1 {
	.sheets.loop_next
	#delimit ;
	collapse2excel
		(sum) nworkers_wt
		(rawsum) nworkers_unw
		(mean) pct_workfromhome
		(mean) meanwage
		(min) blankobs
		[iw=perwt] if (sector == `sval') & (year == `yr')
		using "`xlxname'", by(`occvar') modify sheet("`.sheets.loop_get'");
	#delimit cr
}
}
drop nworkers_unw nworkers_wt meanwage
log close
