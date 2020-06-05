/*
Non-linear least squares estimation on county-level mobility data
*/

// clear
// quietly do "stats/code/prepare_counties_data.do"

// SET MACROS
* Specification number
local experiment 2

* Name of cases variable
local cases act_cases10

* Name of mobility variable
local depvar mobility_work

* Name of sample variable
local in_sample sample_until_sip

* Nonlinear vs linear
local nonlinear 1

* State FE
local state_fe 0

* Day FE
local day_fe 0

* Cases scale
local scale 0.0676

* Other variables
local other_vars

* Cluster variable
local clustvar stwk

* More macros, set automatically based on macros assigned above
if inlist(`experiment', 999) {
	local FD FD_
	
	if `nonlinear' {
		local cases_expr {b0=-1} * ((`scale' * `cases') ^ {b1=0.25} - (`scale' * L_`cases') ^ {b1})
	}
	else {
		local cases_expr {b0=-1} * `scale' * (`cases' - L_`cases')
	}
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
	
	local constant {c0=0} + 
}

if `state_fe' {
	capture tab stateid, gen(d_state)
	local state_fe_vars d_state*
	local constant
}
else {
	local state_fe_vars
}

if `day_fe' {
	capture drop d_nday*
	tab ndays if `in_sample', gen(d_nday)
	
	if `state_fe' {
		drop d_nday1
	}
	
	local day_fe_vars d_nday*
	local constant
}
else {
	local day_fe_vars
}

* Benchmark
if `experiment' == 1 {
	local pvars d_dine_in_ban d_school_closure d_shelter_in_place d_non_essential_closure

	capture drop nl_sample
	gen nl_sample = `in_sample' & !missing(`cases', `depvar')
	
	foreach var of local pvars {
		replace nl_sample = 0 if missing(`var')
	}
	foreach var of local other_vars {
		replace nl_sample = 0 if missing(`var')
	}

	local linear xb: `pvars' `state_fe_vars' `day_fe_vars' `other_vars'
	nl (`depvar' = `constant' `cases_expr' + {`linear'}) if nl_sample, vce(cluster `clustvar')
	drop nl_sample
}
* First differences
else if `experiment' == 2 {
	local pvars FD_d_dine_in_ban FD_d_school_closure FD_d_non_essential_closure FD_d_shelter_in_place
	local depvar FD_`depvar'
	
	capture drop nl_sample
	gen nl_sample = `in_sample' & !missing(`cases', `depvar')
	
	foreach var of local pvars {
		replace nl_sample = 0 if missing(`var')
	}
	foreach var of local other_vars {
		replace nl_sample = 0 if missing(`var')
	}

	local linear xb: `pvars' `state_fe_vars' `day_fe_vars' `other_vars'
	local cases_expr {b0=-1} * ((`scale' * `cases') ^ {b1=0.25} - (`scale' * L_`cases') ^ {b1})
	nl (`depvar' = `cases_expr' + {`linear'}) if nl_sample, vce(cluster `clustvar') noconstant
	drop nl_sample
}

* Subtract policy effects from log mobility
// local pvars jhu_d_dine_in_ban jhu_d_school_closure jhu_d_shelter_in_place jhu_d_entertainment
// gen effect_policy = 0
// foreach var of local pvars {
// 	replace effect_policy = effect_policy + _b[/xb_`var'] * `var'
// }
// gen adj_mobility_work = mobility_work - effect_policy if nl_sample
//
// #delimit ;
// twoway scatter adj_mobility_work act_cases10 if nl_sample,
// 	graphregion(color(gs16)) title("Workplaces mobility less policy effects, JHU policies")
// 	xtitle("Active cases") ytitle("log(m_{ct}) - P_{ct}'\beta");
// #delimit cr
//
// graph export "stats/output/workplaces_less_policy_jhu.png", replace

// * Summary stats comparing policies
// gen our_dates_less_jhu_sip = shelter_in_place - jhu_shelter_in_place if sample_until_sip & date == date("2020-03-19", "YMD")
// gen our_dates_less_jhu_dine = dine_in_ban - jhu_dine_in_ban if sample_until_sip & date == date("2020-03-19", "YMD")
// gen our_dates_less_jhu_school = school_closure - jhu_school_closure if sample_until_sip & date == date("2020-03-19", "YMD")

