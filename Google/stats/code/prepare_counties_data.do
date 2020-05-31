/*
Performs OLS estimation of mobility regressions.
*/

estimates clear
adopath + "../ado"

* Read
clear all
set maxvar 10000
use "build/output/cleaned_counties.dta"

* Declare panel
tsset ctyid date

* Set period of sample
keep if date >= date("2020-02-24", "YMD")

local final_date // "2020-04-15"

if "`final_date'" == "" {
    quietly sum shelter_in_place
	local last_sip = r(max)

	gen sample_until_sip = (date <= shelter_in_place) if !missing(shelter_in_place)
	replace sample_until_sip = 0 if missing(shelter_in_place)
	replace sample_until_sip = 1 if (date <= `last_sip') & missing(shelter_in_place)
	
	gen sample_7d_after_sip = (date <= shelter_in_place + 7) if !missing(shelter_in_place)
	replace sample_7d_after_sip = 0 if missing(shelter_in_place)
	replace sample_7d_after_sip = 1 if (date <= `last_sip' + 7) & missing(shelter_in_place)
	
	local samples sample_until_sip sample_7d_after_sip
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
gen tuesday = (day_of_week == 2)
gen wednesday = (day_of_week == 3)
gen thursday = (day_of_week == 4)
gen friday = (day_of_week == 5)

foreach var of local samples {
    replace `var' = 0 if weekend
}

* First cases
gen d_first_case = cases > 0

* Identify counties with all missing
// by ctyid: egen nmiss = count(mobility_work) if restr_sample
// replace restr_sample = 0 if (nmiss == 0)
// drop nmiss

// * Add Mondays following shelter-in-place, if SIP was over weekend
// gen sip_weekend = inlist(dow(shelter_in_place), 0, 6)

* Week
gen wk = week(date)

* Population weights
gen wgts = population / 10000

* Linear trend
tsset ctyid date
by ctyid: gen ndays = _n - 1

//
//
* Growth rate of cases
gen mavg = (act_cases10 + F.act_cases10) / 2
gen gcases = D.act_cases10 / mavg
replace gcases = 0 if (act_cases10 == 0) & (mavg == 0)

// by ctyid: gen gcases = D.adj_cases10 / L.adj_cases10
// by ctyid: egen avg_gcases = mean(gcases) if restr_sample
// replace avg_gcases = 0 if adj_cases10 == 0
// replace gcases = 0 if missing(gcases)

* Generate first-differenced variables
foreach var of varlist *d_* mobility_work mobility_rr {
	gen FD_`var' = D.`var' if inrange(day_of_week, 2, 5)
}

* Generate leads and lags
// tsset ctyid date
// foreach var of varlist d_* {
// forvalues k = 1/5 {
// 	gen L`k'_`var' = L`k'.`var'
// 	gen F`k'_`var' = F`k'.`var'
// }
// }

//
//
//
// // twoway scatter mobility_work adj_cases90 [aw=wgts] if restr_sample
//
//
// * Tag each county
// egen ctytag = tag(ctyid) if restr_sample
//
//
//
//
// * Average number of cases by county
// by ctyid: egen avg_cases = mean(adj_cases90) if restr_sample
// egen ctag = tag(ctyid) if !missing(avg_cases)

// _pctile avg_cases if ctag, percentiles(5 95)
//
// replace restr_sample = 0 if avg_cases <= r(r1)
// replace restr_sample = 0 if avg_cases >= r(r2)
