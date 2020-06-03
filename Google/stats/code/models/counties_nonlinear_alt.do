/*
Non-linear least squares estimation on county-level mobility data
*/

// clear
// quietly do "stats/code/prepare_counties_data.do"

// SET MACROS
* Specification number
local experiment 1

* Name of cases variable
local cases act_cases10

* Name of mobility variable
local depvar mobility_work

* Name of sample variable
local in_sample sample_until_sip

* Nonlinear vs linear
local nonlinear 1

* Cases scale
local scale 0.0676

* More macros, set automatically based on macros assigned above
if inlist(`experiment', 11, 12, 22, 23) {
	local FD FD_
	
	if `nonlinear' {
		local cases_expr {b0=-1} * ((`scale' * `cases') ^ {b1=0.25} - (`scale' * L_`cases') ^ {b1})
	}
	else {
		local cases_expr {b0=-1} * `scale' * (`cases' - L_`cases')
	local depvar FD_`depvar'
}
else {
	local FD
	if `nonlinear' {
		local cases_expr {b0=-1} * (`scale' * `cases') ^ {b1=0.25}
	}
	else {
		local cases_expr {b0=-1} * `scale' *`cases'
	}
}

local pvars jhu_d_dine_in_ban jhu_d_school_closure jhu_d_shelter_in_place jhu_d_entertainment;

* Benchmark
if `experiment' == 1 {
	capture drop nl_sample

	#delimit ;
	gen nl_sample = `in_sample' &
		!missing(jhu_d_dine_in_ban,
			jhu_d_school_closure,
			jhu_d_entertainment,
			jhu_d_shelter_in_place,
			`cases', `depvar');
	#delimit cr

	local linear xb: `pvars'
	nl (`depvar' = {c0=0} + `cases_expr' + {`linear'}) if nl_sample, vce(cluster stateid) hasconstant(c0)
	drop nl_sample
}
