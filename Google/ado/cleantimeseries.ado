/*
Computes a moving average of raw total cases, then optionally adjusts the moving average of total
cases to an approximation of active cases using the desired recovery rate.
*/

program cleantimeseries

	#delimit ;
	syntax varlist,
		[MA(integer 0)] [RECOVERY(real 0)] [GEN(string)] [PANELID(varlist)]
		[INITIAL(string)];
	#delimit cr

	capture drop `gen'

	* Moving average
	if `ma' > 0 {
		tsset `panelid' date

		local d = (`ma' - 1) / 2

		tempvar vsum vcount
		gen `vsum' = `varlist'
		gen `vcount' = !missing(`varlist')
		forvalues z = 1/`d' {
			replace `vsum' = `vsum' + L`z'.`varlist' if !missing(L`z'.`varlist')
			replace `vcount' = `vcount' + 1 if !missing(L`z'.`varlist')
			
			replace `vsum' = `vsum' + F`z'.`varlist' if !missing(F`z'.`varlist')
			replace `vcount' = `vcount' + 1 if !missing(F`z'.`varlist')
		}
		gen `gen' = `vsum' / `vcount'
		drop `vsum' `vcount'
		replace `gen' = . if missing(`varlist')
	}
	else {
		gen `gen' = `varlist'
	}

	* Adjust for recovery rate
	if `recovery' > 0 {
		tempvar dcases
		gen `dcases' = D.`gen'
		replace `dcases' = 0 if (`gen' == 0) & missing(L.`gen')

		* Assume initial date of 2/24
		tempvar adjusted
		
		local initial = cond("`initial'"=="", "2020-02-24", "`initial'")
		gen `adjusted' = `gen' if date <= date("`initial'", "YMD")

		#delimit ;
		by `panelid': replace `adjusted' =
			cond(date > date("`initial'", "YMD"),
				max(`dcases' + (1 - `recovery') * `adjusted'[_n-1], 0),
				`adjusted');
		#delimit cr
		replace `gen' = `adjusted'

		label variable `gen' "Cases pc, 0`recovery_rate' rec rate"
	}
end
