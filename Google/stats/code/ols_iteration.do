/*
Estimates a variety of models of log mobility.

Note: The stats/output/estimates/ directory is deleted by this script and
recreated.
*/

estimates clear
adopath + "../ado"

* Read
clear all
set maxvar 10000
use "build/output/cleaned_counties.dta"

* Housekeeping
tsset ctyid date

adopath + "ado"
discard
shell rm -rd "stats/output/estimates/"
capture mkdir "stats/output/estimates"

local begin = "2020-02-29"
local end = "SIP"

* Sample restriction
gen in_sample = (date <= shelter_in_place)
quietly sum shelter_in_place
replace in_sample = (date <= r(max)) if missing(shelter_in_place)
replace in_sample = 0 if (date < date("2020-02-29", "YMD"))

* Weekends
gen day_of_week = dow(date)
gen weekend = inlist(day_of_week, 0, 6)

* Create cases variables, 0.1 recovery rate with 3- and 7-day moving avg
// do "stats/code/adjust_active_cases.do" cases 3 0.1 active_cases3
do "stats/code/adjust_active_cases.do" cases 7 0.1 active_cases7

* Estimation
// scalar eps = 1e-4
// scalar maxiters = 100
//
// scalar a1 = 0.1
// scalar a2 = 0.5
//
// iter_ols active_cases7 a1
// scalar r1 = r(rss)
//
// iter_ols active_cases7 a2
// scalar r2 = r(rss)
//
// local i = 0
// while (abs(r1 - r2) > eps) {
// 	local ++i
//	
// 	if (`i' > maxiters) {
// 		continue, break
// 	}
//	
// 	local amid = (a1 + a2) / 2
//
// 	iter_ols active_cases7 `amid'
// 	scalar rmid = r(rss)
//	
// 	if rmid > r1 {
// 		scalar a2 = `amid'
// 		scalar r2 = rmid
// 	}
// 	else {
// 		scalar a1 = `amid'
// 		scalar r1 = rmid
// 	}
// }

local policies d_dine_in_ban d_school_closure d_non_essential_closure d_shelter_in_place

local regressors

foreach var of local policies {
forvalues k = 3(-1)1 {
    gen FF`k'_`var' = F`k'.`var'
	local regressors `regressors' FF`k'_`var'
}

local regressors `regressors' `var'

forvalues k = 1/3 {
    gen LL`k'_`var' = L`k'.`var'
	local regressors `regressors' LL`k'_`var'
}
}

local rssbest = 1000000
local powbest = 0.25

forvalues pow = 0.4(0.0005)0.6 {
    gen scaled = (0.058 * active_cases7) ^ `pow'
	quietly reg mobility_rr scaled `regressors' i.ndays if in_sample & !weekend
	drop scaled

	di as result "power = `pow', rss = `e(rss)'"
	
	if e(rss) < `rssbest' {
	    local rssbest = e(rss)
		local powbest = `pow'
	}
}

gen scaled = (0.058 * active_cases7) ^ `powbest'
reg mobility_rr scaled `regressors' i.ndays if in_sample & !weekend

di as result "power = `powbest'"