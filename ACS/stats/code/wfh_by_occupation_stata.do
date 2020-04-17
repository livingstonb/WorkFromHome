/* --- HEADER ---
This script computes WFH and other statistics for the ACS.
Statistics are computed separately for different occupations
and sectors. Assumes the cwd is ACS.
*/

clear
adopath + "../ado"

// WFH BY OCCUPATION, THREE DIGIT
`#PREREQ' local cleaned "build/output/acs_cleaned.dta"
use "`cleaned'" if inrange(year, 2013, 2018), clear
drop if missing(sector, occ3d2010)

label define bin_lbl 0 "No" 1 "Yes", replace
label define bin_pct_lbl 0 "No" 100 "Yes", replace

gen pct_workfromhome = workfromhome * 100
label variable pct_workfromhome "% WFH"

gen nworkers_unw = !missing(workfromhome)
label variable nworkers_unw "n, unwtd"

gen nworkers_wt = !missing(workfromhome)
label variable nworkers_wt "Total workers in group"

gen meanwage = incwage
label variable meanwage "Mean wage/salary income"

* Add blanks
`#PREREQ' local occ2010 "../occupations/build/output/occindex2010.dta"
#delimit ;
appendblanks soc3d2010 using "`occ2010'",
	gen(blankobs) rename(occ3d2010)
	over1(sector) values1(0 1)
	over2(year) values2(2013 2014 2015 2016 2017 2018);
#delimit cr
drop if (occ3d2010 >= 550) & !missing(occ3d2010)

replace nworkers_wt = 0 if blankobs
replace nworkers_unw = 0 if blankobs
label variable blankobs "Empty category"


// PRODUCE STATA FILE
tempfile acs2017only
preserve
#delimit ;
collapse
	(sum) nworkers_wt (rawsum) nworkers_unw
	(mean) pct_workfromhome (mean) meanwage
	(min) blankobs
	[iw=perwt] if (year == 2017), by(occ3d2010 sector) fast;
#delimit cr
gen source = "ACS2017only"
save `acs2017only', replace

tempfile acs2015to2017
restore

preserve
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