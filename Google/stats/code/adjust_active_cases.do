/*
Computes a moving average of raw total cases, then adjusts the moving average of total
cases to an approximation of active cases using the desired recovery rate.
*/
args ma_periods recovery_rate new_var

capture drop `new_var'

* Moving average
tsset ctyid date

local d = (`ma_periods' - 1) / 2

tempvar vsum vcount
gen `vsum' = cases
gen `vcount' = !missing(cases)
forvalues z = 1/`d' {
	replace `vsum' = `vsum' + L`z'.cases if !missing(L`z'.cases)
	replace `vcount' = `vcount' + 1 if !missing(L`z'.cases)
	
	replace `vsum' = `vsum' + F`z'.cases if !missing(F`z'.cases)
	replace `vcount' = `vcount' + 1 if !missing(F`z'.cases)
}
gen `new_var' = `vsum' / `vcount'
drop `vsum' `vcount'
replace `new_var' = . if missing(cases)

* Adjust for recovery rate
tempvar dcases
gen `dcases' = D.`new_var'
replace `dcases' = 0 if (`new_var' == 0) & missing(L.`new_var')

* Assume initial date of 2/24
tempvar adjusted
gen `adjusted' = `new_var' if date <= date("2020-02-24", "YMD")

#delimit ;
by ctyid: replace `adjusted' =
	cond(date > date("2020-02-24", "YMD"),
		max(`dcases' + (1 - `recovery_rate') * `adjusted'[_n-1], 0),
		`adjusted');
#delimit cr
replace `new_var' = `adjusted'

label variable `new_var' "County cases pc, 0`recovery_rate' rec rate"
