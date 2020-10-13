/*
Computes a moving average of raw total cases.
*/

program movingavg
	syntax varlist, GEN(name) PERIODS(integer) TIME(varname) [, PANEL(varname)]

	capture drop `gen'
	
	if "`panel'" == "" {
		tempvar panelvar
		gen `panelvar' = 1
		local panel `panelvar'
	}

	* Moving average
	tsset `panel' `time'

	local d = (`periods' - 1) / 2

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
end
