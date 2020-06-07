
use "build/output/cleaned_counties.dta", clear

* Tag each county
gen tag = date == date("2020-03-29", "YMD")

* Mobility vs date for all counties in a state
xtline mobility_work if statename == "`state'" & date < date("2020-04-01", "YMD"), overlay

* Scatter of mobility vs date
local state Illinois
local county Cook
twoway scatter act_cases10 date if county == "`county'" & statename == "`state'"

* Mobility vs active cases
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