/* --- HEADER ---
This script computes WFH and other statistics by occupation
and sector.

#PREREQ ../ado/statalist.class
#PREREQ ../ado/createxlsx.ado
#PREREQ ../ado/collapse2excel.ado
*/

`#PREREQ' use "build/output/atus_cleaned.dta", clear
adopath + "../ado"

* Gen new variables
gen pct_canwfh = 100 * canwfh
label variable pct_canwfh "% can WFH"

gen pct_doeswfh = 100 * doeswfh
label variable pct_doeswfh "% does WFH"

gen nworkers_unw = !missing(canwfh, doeswfh)
label variable nworkers_unw "n, unwtd"

gen nworkers_wt = !missing(canwfh, doeswfh)
label variable nworkers_wt "Total workers in group"

gen meanwage = earnwk * 52 if (singjob_fulltime == 1)
label variable meanwage "Mean (wkly earnings * 52), full-time single jobholders only"

* Add blanks
preserve
clear

`#PREREQ' local occ2010 "../occupations/build/output/occindex2010.dta"
tempfile yrtmp
save `yrtmp', emptyok
forvalues sval = 0/1 {
	use soc3d2010 using "`occ2010'", clear
	rename soc3d2010 occ3digit
	gen sector = `sval'
	gen normwt = 1
	gen blankobs = 1
	gen nworkers_wt = 0
	gen nworkers_unw = 0
	duplicates drop occ3digit, force
	
	append using `yrtmp'
	save `yrtmp', replace
}
restore
append using `yrtmp'
drop if (occ3digit >= 550) & !missing(occ3digit)

replace blankobs = 0 if missing(blankobs)
// drop if !missing(can))

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
`#TARGET' save "stats/output/ATUSwfh.dta", replace

restore

* Collapse and make spreadsheet
`#TARGET' local xlxname "stats/output/ATUS_wfh_by_occ.xlsx"

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
