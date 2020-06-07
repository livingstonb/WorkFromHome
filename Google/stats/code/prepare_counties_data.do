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

* Tag each county
gen tag = date == date("2020-03-19", "YMD")

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

* First cases
gen d_first_case = cases > 0

* Week
gen wk = week(date)

* State-week identifier
egen stwk = group(stateid wk)


* Growth rate of cases
gen mavg = (act_cases10 + F.act_cases10) / 2
gen gcases = D.act_cases10 / mavg
replace gcases = 0 if (act_cases10 == 0) & (mavg == 0)


* Duration of SIP
tsset ctyid date
by ctyid: gen duration_sip = sum(d_shelter_in_place)


* Plots
// xtline mobility_work if statename == "Oregon" & date < date("2020-04-01", "YMD") & !weekend, overlay
// twoway scatter act_cases10 date if county == "Cook" & statename == "Illinois"
//

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
