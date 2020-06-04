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

* Shelter-in-place variable
local sip shelter_in_place

if "`final_date'" == "" {
    quietly sum `sip'
	local last_sip = r(max)

	gen sample_until_sip = (date <= `sip') if !missing(`sip')
	replace sample_until_sip = 0 if missing(`sip')
	replace sample_until_sip = 1 if (date <= `last_sip') & missing(`sip')
	
	gen sample_7d_into_sip = (date <= `sip' + 7) if !missing(`sip')
	replace sample_7d_into_sip = 0 if missing(`sip')
	replace sample_7d_into_sip = 1 if (date <= `last_sip' + 7) & missing(`sip')
	
	gen sample_with_7d_after_sip = (date <= `sip') if !missing(`sip')
	#delimit ;
	replace sample_with_7d_after_sip = 1
		if inrange(date, lifted_shelter_in_place, lifted_shelter_in_place + 6)
			& !missing(lifted_shelter_in_place)
			& (lifted_shelter_in_place <= date("2020-05-19", "YMD"));
	#delimit cr
	replace sample_with_7d_after_sip = 0 if missing(`sip')
	replace sample_with_7d_after_sip = 1 if (date <= `last_sip') & missing(`sip')
	
	local samples sample_until_sip sample_7d_into_sip sample_with_7d_after_sip
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

* Week
gen wk = week(date)

* Population weights
gen wgts = population / 10000

* Linear trend
tsset ctyid date
local day1 = date("2020-02-24", "YMD")
gen ndays = date - `day1'

//
//
* Growth rate of cases
gen mavg = (act_cases10 + F.act_cases10) / 2
gen gcases = D.act_cases10 / mavg
replace gcases = 0 if (act_cases10 == 0) & (mavg == 0)

* Generate first-differenced variables
foreach var of varlist *d_* mobility_work mobility_rr {
	gen FD_`var' = D.`var' if inrange(day_of_week, 2, 5)
}

* Duration of SIP
tsset ctyid date
by ctyid: gen duration_sip = sum(`sip')

* Plots
// twoway scatter mobility_work adj_cases90 [aw=wgts] if sample_until_sip
//
// #delimit ;
// twoway scatter mobility_work act_cases10 if sample_until_sip & act_cases10 <= 0.0005,
// 	graphregion(color(gs16)) xtitle("Active infections per capita")
// 	ytitle("Log mobility, workplaces") title("Workplaces mobility vs cases, 2/24-SIP")
// 	msize(vtiny) ;
// #delimit cr
// graph export "stats/output/workplaces_infections_scatter.png", replace
//
// #delimit ;
// twoway scatter mobility_rr act_cases10 if sample_until_sip & act_cases10 <= 0.0005,
// 	graphregion(color(gs16)) xtitle("Active infections per capita")
// 	ytitle("Log mobility, retail and rec") title("Retail and rec mobility vs cases, 2/24-SIP")
// 	msize(vtiny) ;
// #delimit cr
// graph export "stats/output/retail_rec_infections_scatter.png", replace

* Tag each county
// egen ctytag = tag(ctyid) if sample_until_sip

* Average number of cases by county
// by ctyid: egen avg_cases = mean(adj_cases90) if sample_until_sip
// egen tmp_ctag = tag(ctyid) if !missing(avg_cases)
// _pctile avg_cases if tmp_ctag, percentiles(5 95)
// drop tmp_ctag
//
// replace restr_sample = 0 if avg_cases <= r(r1)
// replace restr_sample = 0 if avg_cases >= r(r2)
