clear
capture log close
log using "$ACSstatstemp/wfh_by_occupation.log", replace

local cdate "3_31_20"

// WFH BY OCCUPATION, THREE DIGIT
cd "$ACSdir"
use "$ACScleaned/acs_cleaned.dta" if inrange(year, 2010, 2018), clear
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
save `yrtmp', emptyok
forvalues yr = 2010(1)2017 {
forvalues sval = 0/1 {
	use occ3d2010 using "$WFHshared/occ2010/output/occindex2010new.dta", clear

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

// POOLED YEARS
discard

.xlxnotes = .statalist.new
.xlxnotes.append "Dataset: ACS"
.xlxnotes.append "Sample: 2010-2017 pooled"
.xlxnotes.append "Description: WFH statistics by 3-digit occupation"

local xlxname "$ACSstatsout/ACS_wfh_pooled_`cdate'.xlsx"

.descriptions = .statalist.new
.descriptions.append "Sector S"
.descriptions.append "Sector C"
.descriptions.append "Both sectors"
.sheets = .descriptions.copy
sl_createxlsx .descriptions .sheets .xlxnotes using "`xlxname'"

local occvar occ3d2010

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
		(sum) nworkers_wt
		(rawsum) nworkers_unw
		(mean) pct_workfromhome
		(mean) meanwage
		(min) blankobs
		[iw=perwt] if `conds'
		using "`xlxname'", by(`occvar') modify sheet("`.sheets.loop_get'");
	#delimit cr
}

// YEARLY
discard
.xlxnotes = .statalist.new
.xlxnotes.append "Dataset: ACS"
.xlxnotes.append "Sample: 2010-2018, separated by year"
.xlxnotes.append "Description: WFH statistics by 3-digit occupation"

local xlxname "$ACSstatsout/ACS_wfh_yearly_`cdate'.xlsx"

.descriptions = .statalist.new
forvalues yr = 2010/2018 {
	.descriptions.append "`yr', Sector C"
	.descriptions.append "`yr', Sector S"
	.descriptions.append "`yr', Both sectors"
}
.sheets = .descriptions.copy
sl_createxlsx .descriptions .sheets .xlxnotes using "`xlxname'", title(`title')

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
		using "`xlxname'", by(`occvar') modify sheet("`.sheets.loop_get'");
	#delimit cr
}
}


drop nworkers_unw nworkers_wt meanwage
log close
