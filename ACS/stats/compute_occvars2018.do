// NOTE: FIRST RUN "do macros.do" IN THE MAIN DIRECTORY

/* Dataset: ACS */
/* This script generates occupation-industry-specific variables
and designates certain 3-digit occupations as WFH-flexible or
WFH-rigid. */

clear

capture label define bin_lbl 0 "No" 1 "Yes"
capture label define bin_pct_lbl 0 "No" 100 "Yes"

// COMPUTE OCCUPATION STATISTICS, THREE DIGIT OCC

* Collapse by occ3d2018
use "$ACSbuild/cleaned/acs_cleaned.dta" if (year == 2018), clear
drop if missing(sector, occ3d2018)

gen nrespondents3digit = 1
gen nworkers3digit = 1
gen wfh3digit = 100 * workfromhome

#delimit ;
collapse (median) medwage3digit=incwage (mean) meanwage3digit=incwage
	(mean) wfh3digit (rawsum) nrespondents3digit (sum) nworkers3digit
	[iw=perwt], by(occ3d2018) fast;
#delimit cr

gen year = 2018
order year occ3d2018

label variable medwage3digit "Median wage"
label variable meanwage3digit "Mean wage"
label variable wfh3digit "%WFH"
label variable nrespondents3digit "n"
label variable nworkers3digit "Total workers"

* WFH-flexibility, threshold at 4%
gen wfhflex3digit = (wfh3digit >= 4) & !missing(wfh3digit)
label variable wfhflex3digit "WFH-flexible occupation"
label define wfhflex3digit_lbl 0 "Rigid" 1 "Flexible"
label values wfhflex3digit wfhflex3digit_lbl

tempfile occ3dtemp
save `occ3dtemp'

* Collapse by WFH flexibility
use "$ACSbuild/cleaned/acs_cleaned.dta" if (year == 2018), clear
drop if missing(sector, occ3d2018)

merge m:1 occ3d2018 using `occ3dtemp', nogen keepusing(wfhflex3digit)

gen nworkers_2occ = 1

#delimit ;
collapse (mean) meanwage_2occ=incwage
	(sum) nworkers_2occ
	[iw=perwt], by(wfhflex3digit) fast;
#delimit cr

label variable meanwage_2occ "Mean wage for flex/rigid occ"
label variable nworkers_2occ "Total workers for flex/rigid occ"

tempfile occflextemp
save `occflextemp'

* Combine occfine and wfh-flex data
use `occ3dtemp', clear
merge m:1 wfhflex3digit using `occflextemp', nogen

compress
save "$ACSbuild/cleaned/occ_group_stats.dta", replace


// COMPUTE OCC-INDUSTRY STATISTICS
use "$ACSbuild/cleaned/acs_cleaned.dta" if (year == 2018), clear
drop if missing(sector, occ3d2018)

* Merge with WFH stats by occupation
#delimit ;
merge m:1 occ3d2018 using "$ACSbuild/cleaned/occ_group_stats.dta",
	keepusing(meanwage_2occ wfhflex3digit) nogen;
#delimit cr

* Total workers in each occ-industry
bysort wfhflex3digit sector: egen nworkers_occsec = total(perwt)
bysort sector: egen nworkers_sec = total(perwt)

bysort wfhflex3digit sector: gen ioshare = nworkers_occsec / nworkers_sec

#delimit ;
collapse (firstnm) ioshare (firstnm) meanwage_2occ
	(firstnm) nworkers_occsec (firstnm) nworkers_sec
	, by(wfhflex3digit sector);
#delimit cr

rename wfhflex3digit flex_occ
rename meanwage_2occ meanw_flex_occ

label variable ioshare "Share of sector workers in given occupation"
label variable meanw_flex_occ "Mean wage in occ"
label variable nworkers_occsec "Workers in occ-sector"
label variable nworkers_sec "Workers in sector"

order sector flex_occ ioshare
sort sector flex_occ
