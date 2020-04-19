/* --- HEADER ---
This script computes various asset, earnings, and WFH statistics
for SIPP and outputs them to a spreadsheet.
*/

adopath + "../ado"

`#PREREQ' use "build/output/sipp_cleaned.dta", clear

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

foreach var of varlist qualitative_h2m foodinsecure nla* whtm* phtm* {
	local meanstats `meanstats' (mean) `var'
}

gen nworkers_unw = !missing(workfromhome)
label variable nworkers_unw "n, unwtd"

gen nworkers_wt = !missing(workfromhome)
label variable nworkers_wt "Total"

* Add blanks
`#PREREQ' local occ2010 "../occupations/build/output/census2010_to_soc2010.dta"
#delimit ;
appendblanks soc3d2010 using "`occ2010'",
	gen(blankobs) over1(sector) values1(0 1)
	over2(swave) values2(0 1) rename(occ3d2010);
#delimit cr

replace nworkers_wt = 0 if blankobs
replace nworkers_unw = 0 if blankobs
label variable blankobs "Empty category"

drop if missing(sector, occ3d2010)
rename workfromhome pct_workfromhome
rename earnings meanwage

* Collapse
#delimit ;
collapse
	(sum) nworkers_wt (rawsum) nworkers_unw
	(mean) pct_workfromhome (mean) meanwage
	`meanstats' `medianstats'
	(min) blankobs
	[iw=wpfinwgt], by(sector occ3d2010) fast;
#delimit cr

drop mean_earnings
drop median_earnings
gen source = "SIPP"

drop blankobs
`#TARGET' save "stats/output/SIPPwfh.dta", replace
