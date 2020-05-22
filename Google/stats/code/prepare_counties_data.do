/*
Performs OLS estimation of mobility regressions.
*/

estimates clear
adopath + "../ado"

* Read
use "build/output/cleaned_counties.dta", clear

* Declare panel
tsset ctyid date

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
gen sunday = (day_of_week == 0)
gen saturday = (day_of_week == 6)
gen monday = (day_of_week == 1)
replace restr_sample = 0 if weekend

* Identify counties with all missing
by ctyid: egen nmiss = count(mobility_work) if restr_sample
replace restr_sample = 0 if (nmiss == 0)
drop nmiss

// * Add Mondays following shelter-in-place, if SIP was over weekend
// gen sip_weekend = inlist(dow(shelter_in_place), 0, 6)

* Week
gen wk = week(date)


* Growth rate of cases
by ctyid: gen gcases = D.adj_cases90 / L.adj_cases90
by ctyid: egen avg_gcases = mean(gcases) if restr_sample
replace avg_gcases = 0 if adj_cases90 == 0
replace gcases = 0 if missing(gcases)

* Generate first-differenced variables
foreach var of varlist *d_* mobility_work mobility_rr {
	gen FD_`var' = D.`var' if inrange(day_of_week, 2, 5)
}



* Population weights
gen wgts = population / 10000
// twoway scatter mobility_work adj_cases90 [aw=wgts] if restr_sample


* Tag each county
egen ctytag = tag(ctyid) if restr_sample




* Average number of cases by county
by ctyid: egen avg_cases = mean(adj_cases90) if restr_sample
egen ctag = tag(ctyid) if !missing(avg_cases)

// _pctile avg_cases if ctag, percentiles(5 95)
//
// replace restr_sample = 0 if avg_cases <= r(r1)
// replace restr_sample = 0 if avg_cases >= r(r2)
