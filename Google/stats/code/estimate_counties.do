/*
Performs OLS estimation of mobility regressions.
*/

estimates clear
adopath + "../ado"

* Read
use "build/output/cleaned_counties.dta", clear

* Declare panel
tsset ctyid date

// rename agg_cases raw_natl_cases
// moving_average raw_natl_cases, time(date) panelid(stateid) gen(natl_cases) nperiods(3)
// label variable natl_cases "US cases per person"

gen sq_cases = cases ^ 2
label variable sq_cases "Sq state cases per person"

gen sqrt_cases = cases ^ (1/4)
label variable sqrt_cases "Sqrt state cases per person"
//
// gen sq_natl_cases = natl_cases ^ 2
// label variable sq_natl_cases "Sq US cases per person"

// gen sqrt_natl_cases = natl_cases ^ (1/4)

// gen exp_cases = F7.cases
// replace exp_cases = 0 if date < date("2020-03-13", "YMD")
//
// gen sq_exp_cases = exp_cases ^ 2


* Set period of sample
keep if date >= date("2020-02-24", "YMD")

local final_date // "2020-04-15"

if "`final_date'" == "" {
	gen restr_sample = (date <= shelter_in_place) if !missing(shelter_in_place)

	quietly sum shelter_in_place
	replace restr_sample = 0 if missing(shelter_in_place)
	replace restr_sample = 1 if (date <= `r(max)') & missing(shelter_in_place)
}
else {
	gen restr_sample =  (date <= date("`final_date'", "YMD"))
}


* Weekends
gen day_of_week = dow(date)
gen weekend = inlist(day_of_week, 0, 6)
replace restr_sample = 0 if weekend

* Identify counties with all missing
by ctyid: egen nmiss = count(mobility_work) if restr_sample
replace restr_sample = 0 if (nmiss == 0)
drop nmiss

// * Add Mondays following shelter-in-place, if SIP was over weekend
// gen sip_weekend = inlist(dow(shelter_in_place), 0, 6)

* Week
gen wk = week(date)

* Regression
encode state, gen(stateid)
reg mobility_work cases d_dine_in_ban d_school_closure d_non_essential_closure d_shelter_in_place if restr_sample, vce(cluster stateid)
