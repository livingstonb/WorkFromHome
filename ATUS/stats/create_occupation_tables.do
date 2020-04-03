// NOTE: FIRST RUN "do macros.do" IN THE MAIN DIRECTORY

/* Dataset: ACS */
/* This script computes WFH and other statistics by occupation
and sector. */

use "$ATUSbuild/output/ATUS_cleaned.dta", clear

* Gen new variables
gen pct_canwfh = 100 * canwfh
label variable pct_canwfh "% can WFH"

gen pct_doeswfh = 100 * doeswfh
label variable pct_doeswfh "% does WFH"

gen nworkers_unw = 1
label variable nworkers_unw "n, unwtd"

gen nworkers_wt = 1
label variable nworkers_wt "Total workers in group"

gen meanwage = earnwk * 52 if (singjob_fulltime == 1)
label variable meanwage "Mean (wkly earnings * 52), full-time single jobholders only"

* Add blanks
tempfile yrtmp
preserve
save `yrtmp', emptyok
forvalues sval = 0/1 {
	use occ3d2010 using "$WFHshared/occ2010/output/occindex2010new.dta", clear
	rename occ3d2010 occ3digit
	gen sector = `sval'
	gen normwt = 1
	gen blankobs = 1
	
	append using `yrtmp'
	save `yrtmp', replace
}
restore
append using `yrtmp'
drop if (occ3digit >= 550) & !missing(occ3digit)

replace blankobs = 0 if missing(blankobs)
replace nworkers_wt = 0 if (blankobs == 1)
replace nworkers_unw = 0 if (blankobs == 1)
label variable blankobs "Empty category"

foreach var of varlist nworkers_unw nworkers_wt {
	replace `var' = 0 if (blankobs == 1)
}

replace blankobs = 0 if missing(blankobs)
label variable blankobs "Empty category"

* Collapse and make .dta file
preserve
rename pct_doeswfh pct_workfromhome
rename occ3digit occ3d2010
drop if missing(occ3d2010, sector)

#delimit ;
collapse (sum) nworkers_wt
		(rawsum) nworkers_unw
		(mean) pct_canwfh
		(mean) pct_workfromhome
		(mean) meanwage
		(min) blankobs
		[iw=normwt], by(occ3d2010 sector) fast;
#delimit cr

gen source = "ATUS"
save "$ATUSstatsout/ATUSwfh.dta", replace

restore

* Collapse and make spreadsheet
local xlxname "$ATUSstatsout/ATUS_wfh_by_occ3digit_sector.xlsx"

.xlxnotes = .statalist.new
.xlxnotes.append "Dataset: ATUS"
.xlxnotes.append "Sample: 2017-2018 with Leave Module"
.xlxnotes.append "Description: WFH statistics by 3-digit occupation"

.descriptions = .statalist.new
.descriptions.append "Sector C"
.descriptions.append "Sector S"
.sheets = .descriptions.copy
createxlsx .descriptions .sheets .xlxnotes using "`xlxname'"

.sheets.loop_reset
forvalues sval = 0/1 {
	.sheets.loop_next

	#delimit ;
	collapse2excel
		(sum) nworkers_wt
		(rawsum) nworkers_unw
		(mean) pct_canwfh
		(mean) pct_doeswfh
		(mean) meanwage
		(min) blankobs
		[iw=normwt] if (sector == `sval')
		using "`xlxname'", by(occ3digit) modify sheet("`.sheets.loop_get'");
	#delimit cr
}
