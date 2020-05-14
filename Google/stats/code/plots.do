
args state

preserve

tempvar lcases dlcases
gen `lcases' = log(cases)
gen `dlcases' = d.`lcases'

label variable `lcases' "Log new cases per 10,000 people"
label variable `dlcases' "Log diff new cases per 10,000 people"

quietly sum stay_at_home if statename == "`state'"
local order_date = `r(min)'

#delimit ;
twoway line `lcases' date if statename == "`state'",
	graphregion(color(gs16)) title("`state'") xline(`order_date');
#delimit cr

graph export "stats/output/`state'_new_cases.png", replace

#delimit ;
twoway line `dlcases' date if statename == "`state'",
	graphregion(color(gs16)) title("`state'") xline(`order_date');
#delimit cr

graph export "stats/output/`state'_diff_new_cases.png", replace
