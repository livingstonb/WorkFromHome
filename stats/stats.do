clear

global stats "$maindir/stats"
global statsout "$stats/output"
capture mkdir "$statsout"

use "$build/cleaned/acs_cleaned.dta", clear

* part time vs. full time
* by education
* by race, sex
* by wage quintile
* by age
* by having health insurance
* work difficulty

* workfromhome
* wfh_not_selfemp
* wfh_women
* wfh_men
* wfh_excl

// DROP VARIABLES
drop if (year < 2010)

// WAGE QUINTILES
gen wage_quintile = .
forvalues yr = 2000/2018 {
	xtile tmp = incwage [pw=perwt] if (year == `yr'), nq(5)
	replace wage_quintile = tmp if (year == `yr')
	drop tmp
}
label variable wage_quintile "Wage quintile within the given year"


