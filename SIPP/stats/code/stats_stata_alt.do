/* --- HEADER ---
This script computes various asset, earnings, and WFH statistics
for SIPP and outputs them to a spreadsheet.
*/

args sunit

adopath + "../ado"

// Read
`#PREREQ' use "build/output/annual_`sunit'.dta", clear

// MEAN AND MEDIAN VARIABLES FOR COLLAPSE
#delimit ;
local stats pdeposits pbonds pliqequity liquid_nocash liquid_wcash ccdebt earnings
	netliquid netliq_earnings_ratio netilliquid;
#delimit cr

label variable foodinsecure "Share who cut or skipped meals b/c not enough money"
label variable qualitative_h2m "Share who cut or skipped meals or couldn't pay utilities"

local meanstats
local medianstats
foreach var of local stats {
	local varlab: variable label `var'

	gen mean_`var' = `var'
	gen median_`var' = `var'
	label variable mean_`var' "Mean `varlab'"
	label variable median_`var' "Median `varlab'"
	local meanstats `meanstats' (mean) mean_`var'
	local medianstats `medianstats' (median) median_`var'
}

foreach var of varlist qualitative_h2m foodinsecure nla* whtm* phtm* htm* {
	local meanstats `meanstats' (mean) `var'
}

gen nworkers_unw = !missing(workfromhome)
label variable nworkers_unw "n, unwtd"

gen nworkers_wt = !missing(workfromhome)
label variable nworkers_wt "Total"

rename workfromhome pct_workfromhome
rename earnings meanwage

// Collapse at the 3-digit level
preserve

varlabels, save

* Add blanks
`#PREREQ' local blanks "../occupations/build/output/soc3dvalues2010.dta"
#delimit ;
appendblanks soc3d2010 using "`blanks'",
	zeros(nworkers_wt nworkers_unw) ones(swgts)
	over1(sector) values1(0 1) rename(occ3d2010);
#delimit cr

drop if missing(sector, occ3d2010)

#delimit ;
collapse
	(sum) nworkers_wt (rawsum) nworkers_unw
	(mean) pct_workfromhome (mean) meanwage
	`meanstats' `medianstats'
	(min) blankobs
	[iw=swgts], by(sector occ3d2010) fast;
#delimit cr

varlabels, restore

drop mean_earnings
drop median_earnings
gen source = "SIPP"
label variable source "Dataset"

drop blankobs
`#TARGET' save "stats/output/SIPP3d_`sunit'.dta", replace
restore

// Collapse at the 5-digit level, by sector and for both sectors
preserve

varlabels, save

* Add blanks
`#PREREQ' local blanks "../occupations/build/output/soc5dvalues2010.dta"
#delimit ;
appendblanks soc5d2010 using "`blanks'",
	zeros(nworkers_wt nworkers_unw) ones(swgts)
	over1(sector) values1(0 1) rename(occ5d2010);
#delimit cr

drop if missing(sector, occ5d2010)

tempfile cleaned
save `cleaned'

* Collapse by sector
tempfile bysector
#delimit ;
collapse
	(sum) nworkers_wt (rawsum) nworkers_unw
	(mean) pct_workfromhome (mean) meanwage
	`meanstats' `medianstats'
	(min) blankobs
	[iw=swgts], by(sector occ5d2010) fast;
#delimit cr
save `bysector'

* Collapse for both sectors
use `cleaned', clear
#delimit ;
collapse
	(sum) nworkers_wt (rawsum) nworkers_unw
	(mean) pct_workfromhome (mean) meanwage
	`meanstats' `medianstats'
	(min) blankobs
	[iw=swgts], by(occ5d2010) fast;
#delimit cr

* Combine
append using `bysector'
replace sector = 2 if missing(sector)
label define sector_lbl 2 "Pooled", modify

varlabels, restore

drop mean_earnings
drop median_earnings

if "`sunit'" == "person" {
	gen sunit = 0
}
else if "`sunit'" == "fam" {
	gen sunit = 1
}
else if "`sunit'" == "hh" {
	gen sunit = 2
}
label variable sunit "Sampling unit"

label define sunit_lbl 0 "Person"
label define sunit_lbl 1 "Family", add
label define sunit_lbl 2 "Household", add
label values sunit sunit_lbl

local varorder occ5d2010 sector
order `varorder'
sort `varorder'

drop blankobs
`#TARGET' save "stats/output/SIPP5d_`sunit'.dta", replace
restore
