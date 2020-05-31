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

* More macros, set automatically based on macros assigned above
if inlist(`experiment', 11, 12) {
	local FD FD_
	
	if `nonlinear' {
		local cases_expr {b0=-1} * (`cases' ^ {b1=0.25} - L_`cases'^ {b1})
	}
	else {
		local cases_expr {b0=-1} * (`cases' - L_`cases')
	}
// 	local cases_expr ({b0=-1} + {b2=1} * rural) * (`cases' ^ {b1=0.25} - L_`cases'^ {b1})
	local depvar FD_`depvar'
}
else {
	local FD
// 	local cases_expr ({b0=-1} + {b2=1} * rural) * `cases' ^ {b1=0.25}
//
	if `nonlinear' {
		local cases_expr {b0=-1} * `cases' ^ {b1=0.25}
	}
	else {
		local cases_expr {b0=-1} * `cases'
	}
}

#delimit ;
local pvars `FD'd_dine_in_ban `FD'd_school_closure `FD'd_non_essential_closure
	`FD'd_shelter_in_place;

local plags `FD'L1_d_dine_in_ban `FD'L1_d_school_closure `FD'L1_d_non_essential_closure `FD'L1_d_shelter_in_place;

local pleads `FD'F1_d_dine_in_ban `FD'F1_d_school_closure `FD'F1_d_non_essential_closure `FD'F1_d_shelter_in_place;
#delimit cr

* Benchmark
if `experiment' == 1 {
	capture drop nl_sample

	#delimit ;
	gen nl_sample = `in_sample' &
		!missing(d_dine_in_ban, d_school_closure,
			d_non_essential_closure, d_shelter_in_place,
			`cases', `depvar');
	#delimit cr

	local linear xb: `pvars'
	nl (`depvar' = `cases_expr' + {`linear'}) if nl_sample, vce(cluster stateid) noconstant
	drop nl_sample
}

* Leads and lags
else if `experiment' == 2 {
	capture drop nl_sample

	#delimit ;
	gen nl_sample = `in_sample' &
		!missing(d_dine_in_ban, d_school_closure,
			d_non_essential_closure, d_shelter_in_place,
			L1_d_dine_in_ban, L1_d_school_closure,
			F1_d_dine_in_ban, F1_d_school_closure, L1_d_shelter_in_place,
			L1_d_non_essential_closure, F1_d_non_essential_closure,
			F1_d_shelter_in_place,
			`cases', `depvar');
	#delimit cr

	local linear xb: `pvars' `pleads' `plags'
	nl (`depvar' = `cases_expr' + {`linear'}) if nl_sample, vce(cluster stateid) noconstant
	drop nl_sample
}

* Population-weighted
else if `experiment' == 3 {
	capture drop nl_sample
	
	#delimit ;
	gen nl_sample = `in_sample' &
		!missing(d_dine_in_ban, `FD'd_school_closure,
			d_non_essential_closure, `FD'd_shelter_in_place,
			`cases', `depvar', wgts);
	#delimit cr

	local linear xb: `pvars'
	nl (`depvar' = `cases_expr' + {`linear'}) [iw=wgts] if nl_sample, robust noconstant

	drop nl_sample
}

* Weighted, leads and lags
else if `experiment' == 4 {
	capture drop nl_sample

	#delimit ;
	gen nl_sample = `in_sample' &
		!missing(d_dine_in_ban, d_school_closure,
			d_non_essential_closure, d_shelter_in_place,
			Ld_dine_in_ban, Ld_school_closure,
			Fd_dine_in_ban, Fd_school_closure, Ld_shelter_in_place
			Ld_non_essential_closure, Fd_non_essential_closure,
			Fd_shelter_in_place, wgts,
			`cases', `depvar');
	#delimit cr

	local linear xb: `pvars' `pleads' `plags'
	nl (`depvar' = `cases_expr' + {`linear'}) [iw=wgts] if nl_sample, robust noconstant
	drop nl_sample
}

* State-specific fixed effect
else if `experiment' == 5 {
	capture drop nl_sample
	capture drop d_state*

	tab stateid, gen(d_state)

	#delimit ;
	gen nl_sample = `in_sample' &
		!missing(d_dine_in_ban, d_school_closure,
			d_non_essential_closure, d_shelter_in_place,
			`cases', `depvar');
	#delimit cr

	local linear xb: `pvars' d_state*
	nl (`depvar' = `cases_expr' + {`linear'}) if nl_sample, vce(cluster stateid) noconstant
	drop nl_sample d_state*
}

* State-specific coefficients on policies
else if `experiment' == 6 {
	capture drop nl_sample
	capture drop d_state*

	tab stateid, gen(d_state)
	
	levelsof stateid, local(states)
	local stmacro
	foreach st of local states {
	foreach var of local pvars {
		gen state`st'_`var' = `var' * (stateid == `st')
		local stmacro `stmacro' state`st'_`var'
	}
	}

	#delimit ;
	gen nl_sample = `in_sample' &
		!missing(d_dine_in_ban, d_school_closure,
			d_non_essential_closure, d_shelter_in_place,
			`cases', `depvar');
	#delimit cr

	local linear xb: `pvars' `stmacro'
	nl (`depvar' = `cases_expr' + {`linear'}) if nl_sample, vce(cluster stateid) noconstant
	drop nl_sample d_state* state*_d_*
}

* State-specific fixed effects and coefficients on policies
else if `experiment' == 7 {
	capture drop nl_sample
	capture drop d_state*

	tab stateid, gen(d_state)
	
	levelsof stateid, local(states)
	local stmacro
	foreach st of local states {
	foreach var of local pvars {
		gen state`st'_`var' = `var' * (stateid == `st')
		local stmacro `stmacro' state`st'_`var'
	}
	}

	#delimit ;
	gen nl_sample = `in_sample' &
		!missing(d_dine_in_ban, d_school_closure,
			d_non_essential_closure, d_shelter_in_place,
			`cases', `depvar');
	#delimit cr

	local linear xb: `pvars' `stmacro' d_state*
	nl (`depvar' = `cases_expr' + {`linear'}) if nl_sample, vce(cluster stateid) noconstant
	drop nl_sample d_state* state*_d_*
}

* With state-specific 3/13 dummy
else if `experiment' == 8 {
	capture drop nl_sample
	capture drop d_state*

	tab stateid, gen(d_state)
	
	levelsof stateid, local(states)
	local stmacro
	foreach st of local states {
		gen state`st'_march13 = d_march13 * (stateid == `st')
		local stmacro `stmacro' state`st'_march13
	}

	#delimit ;
	gen nl_sample = `in_sample' &
		!missing(d_dine_in_ban, d_school_closure,
			d_non_essential_closure, d_shelter_in_place,
			`cases', `depvar');
	#delimit cr

	local linear xb: `pvars' state*_march13
	nl (`depvar' = `cases_expr' + {`linear'}) if nl_sample, vce(cluster stateid) noconstant
	drop nl_sample d_state*
}

* New cases instead of total
else if `experiment' == 9 {
	capture drop nl_sample
	capture drop new_cases
	gen new_cases = D.`cases'
	replace new_cases = 0 if new_cases < 0
	
	#delimit ;
	gen nl_sample = `in_sample' &
		!missing(d_dine_in_ban, d_school_closure,
			d_non_essential_closure, d_shelter_in_place,
			new_cases, `depvar');
	#delimit cr

	local cases_expr {b0=-1} * new_cases ^ {b1=0.25}
	local linear xb: `pvars'
	nl (`depvar' = `cases_expr' + {`linear'}) if nl_sample, vce(cluster stateid) noconstant
	drop nl_sample
}

* New deaths, weighted
else if `experiment' == 10 {
	capture drop nl_sample
	capture drop new_deaths

	gen new_deaths = D.deaths

	replace new_deaths = 0 if new_deaths < 0
	
	#delimit ;
	gen nl_sample = `in_sample' &
		!missing(d_dine_in_ban, d_school_closure,
			d_non_essential_closure, d_shelter_in_place,
			new_deaths, `depvar');
	#delimit cr

	local cases_expr {b0=-1} * new_deaths ^ {b1=0.25}
	local linear xb: `pvars'
	nl (`depvar' = `cases_expr' + {`linear'}) [iw=wgts] if nl_sample, robust noconstant

	drop nl_sample
}

* First differences
else if `experiment' == 11 {
	capture drop nl_sample
	
	#delimit ;
	gen nl_sample = `in_sample' &
		!missing(FD_d_dine_in_ban, FD_d_school_closure,
			FD_d_non_essential_closure, FD_d_shelter_in_place,
			`cases', L_`cases', `depvar');
	#delimit cr

	local linear xb: `pvars'
	nl (`depvar' = `cases_expr' + {`linear'}) if nl_sample, robust noconstant

	drop nl_sample
}

* First differences, weighted
else if `experiment' == 12 {
	capture drop nl_sample
	
	#delimit ;
	gen nl_sample = `in_sample' &
		!missing(FD_d_dine_in_ban, FD_d_school_closure,
			FD_d_non_essential_closure, FD_d_shelter_in_place,
			`cases', L_`cases', `depvar');
	#delimit cr

	local linear xb: `pvars'
	nl (`depvar' = `cases_expr' + {`linear'}) [aw=wgts] if nl_sample, robust noconstant

	drop nl_sample
}

* Linear time trend
if `experiment' == 13 {
	capture drop nl_sample

	#delimit ;
	gen nl_sample = `in_sample' &
		!missing(d_dine_in_ban, d_school_closure,
			d_non_essential_closure, d_shelter_in_place,
			`cases', `depvar');
	#delimit cr

	local linear xb: `pvars' ndays
	nl (`depvar' = `cases_expr' + {`linear'}) if nl_sample, vce(cluster stateid) noconstant
	drop nl_sample
}

* County fixed effect
if `experiment' == 14 {
	capture drop nl_sample
	capture drop d_cty*
	
	tab ctyid if `in_sample', gen(d_cty)

	#delimit ;
	gen nl_sample = `in_sample' &
		!missing(d_dine_in_ban, d_school_closure,
			d_non_essential_closure, d_shelter_in_place,
			`cases', `depvar');
	#delimit cr

	local linear xb: `pvars' d_cty*
	nl (`depvar' = `cases_expr' + {`linear'}) if nl_sample, vce(cluster stateid) noconstant
	drop nl_sample
}

* Many leads and lags
if `experiment' == 15 {
	capture drop nl_sample

	#delimit ;
	gen nl_sample = `in_sample' &
		!missing(L5_d_dine_in_ban, L4_d_dine_in_ban, L3_d_dine_in_ban, L2_d_dine_in_ban, L1_d_dine_in_ban,
			d_dine_in_ban,
			F1_d_dine_in_ban, F2_d_dine_in_ban, F3_d_dine_in_ban, F4_d_dine_in_ban, F5_d_dine_in_ban,
			L5_d_school_closure, L4_d_school_closure, L3_d_school_closure, L2_d_school_closure, L1_d_school_closure,
			d_school_closure,
			F1_d_school_closure, F2_d_school_closure, F3_d_school_closure, F4_d_school_closure, F5_d_school_closure,
			L5_d_non_essential_closure, L4_d_non_essential_closure, L3_d_non_essential_closure, L2_d_non_essential_closure, L1_d_non_essential_closure,
			d_non_essential_closure,
			F1_d_non_essential_closure, F2_d_non_essential_closure, F3_d_non_essential_closure, F4_d_non_essential_closure, F5_d_non_essential_closure,
			d_shelter_in_place,
			`cases', `depvar');
	
	local pvars L5_d_dine_in_ban L4_d_dine_in_ban L3_d_dine_in_ban L2_d_dine_in_ban L1_d_dine_in_ban
			d_dine_in_ban
			F1_d_dine_in_ban F2_d_dine_in_ban F3_d_dine_in_ban F4_d_dine_in_ban F5_d_dine_in_ban
			L5_d_school_closure L4_d_school_closure L3_d_school_closure L2_d_school_closure L1_d_school_closure
			d_school_closure
			F1_d_school_closure F2_d_school_closure F3_d_school_closure F4_d_school_closure F5_d_school_closure
			L5_d_non_essential_closure L4_d_non_essential_closure L3_d_non_essential_closure L2_d_non_essential_closure L1_d_non_essential_closure
			d_non_essential_closure
			F1_d_non_essential_closure F2_d_non_essential_closure F3_d_non_essential_closure F4_d_non_essential_closure F5_d_non_essential_closure
			d_shelter_in_place
			F1_d_shelter_in_place F2_d_shelter_in_place F3_d_shelter_in_place F4_d_shelter_in_place F5_d_shelter_in_place;
	#delimit cr

	local linear xb: `pvars'
	nl (`depvar' = `cases_expr' + {`linear'}) if nl_sample, vce(cluster stateid) noconstant
	drop nl_sample
}

* Day-of-week dummies
if `experiment' == 16 {
	capture drop nl_sample

	#delimit ;
	gen nl_sample = `in_sample' &
		!missing(d_dine_in_ban, d_school_closure,
			d_non_essential_closure, d_shelter_in_place,
			`cases', `depvar');
	#delimit cr

	local linear xb: `pvars' monday tuesday wednesday thursday friday
	nl (`depvar' = `cases_expr' + {`linear'}) if nl_sample, vce(cluster stateid) noconstant
	drop nl_sample
}

* Day fixed effects
if `experiment' == 17 {
	capture drop nl_sample
	capture drop d_nday
	
	tab nday if `in_sample', gen(d_nday)

	#delimit ;
	gen nl_sample = `in_sample' &
		!missing(d_dine_in_ban, d_school_closure,
			d_non_essential_closure, d_shelter_in_place,
			`cases', `depvar');
	#delimit cr

	local linear xb: `pvars' d_nday*
	nl (`depvar' = `cases_expr' + {`linear'}) if nl_sample, vce(cluster stateid) noconstant
	drop nl_sample
}
* State FE, linear time trend, and leads and lags
if `experiment' == 18 {
	capture drop nl_sample
	
	capture drop d_state*

	tab stateid, gen(d_state)

	#delimit ;
	gen nl_sample = `in_sample' &
		!missing(L5_d_dine_in_ban, L4_d_dine_in_ban, L3_d_dine_in_ban, L2_d_dine_in_ban, L1_d_dine_in_ban,
			d_dine_in_ban,
			F1_d_dine_in_ban, F2_d_dine_in_ban, F3_d_dine_in_ban, F4_d_dine_in_ban, F5_d_dine_in_ban,
			L5_d_school_closure, L4_d_school_closure, L3_d_school_closure, L2_d_school_closure, L1_d_school_closure,
			d_school_closure,
			F1_d_school_closure, F2_d_school_closure, F3_d_school_closure, F4_d_school_closure, F5_d_school_closure,
			L5_d_non_essential_closure, L4_d_non_essential_closure, L3_d_non_essential_closure, L2_d_non_essential_closure, L1_d_non_essential_closure,
			d_non_essential_closure,
			F1_d_non_essential_closure, F2_d_non_essential_closure, F3_d_non_essential_closure, F4_d_non_essential_closure, F5_d_non_essential_closure,
			d_shelter_in_place,
			`cases', `depvar');
	
	local pvars L5_d_dine_in_ban L4_d_dine_in_ban L3_d_dine_in_ban L2_d_dine_in_ban L1_d_dine_in_ban
			d_dine_in_ban
			F1_d_dine_in_ban F2_d_dine_in_ban F3_d_dine_in_ban F4_d_dine_in_ban F5_d_dine_in_ban
			L5_d_school_closure L4_d_school_closure L3_d_school_closure L2_d_school_closure L1_d_school_closure
			d_school_closure
			F1_d_school_closure F2_d_school_closure F3_d_school_closure F4_d_school_closure F5_d_school_closure
			L5_d_non_essential_closure L4_d_non_essential_closure L3_d_non_essential_closure L2_d_non_essential_closure L1_d_non_essential_closure
			d_non_essential_closure
			F1_d_non_essential_closure F2_d_non_essential_closure F3_d_non_essential_closure F4_d_non_essential_closure F5_d_non_essential_closure
			d_shelter_in_place
			F1_d_shelter_in_place F2_d_shelter_in_place F3_d_shelter_in_place F4_d_shelter_in_place F5_d_shelter_in_place;
	#delimit cr

	local linear xb: `pvars' ndays d_state*
	nl (`depvar' = `cases_expr' + {`linear'}) if nl_sample, vce(cluster stateid) noconstant
	drop nl_sample
}

* State FE and day fixed effects
if `experiment' == 19 {
	capture drop nl_sample
	capture drop d_nday
	capture drop d_state*

	tab stateid, gen(d_state)
	
	tab nday if `in_sample', gen(d_nday)

	#delimit ;
	gen nl_sample = `in_sample' &
		!missing(d_dine_in_ban, d_school_closure,
			d_non_essential_closure, d_shelter_in_place,
			`cases', `depvar');
	#delimit cr

	local linear xb: `pvars' d_nday* d_state*
	nl (`depvar' = `cases_expr' + {`linear'}) if nl_sample, vce(cluster stateid) noconstant
	drop nl_sample
}

* Many leads and lags, post-SIP
if `experiment' == 20 {
	capture drop nl_sample

	#delimit ;
	gen nl_sample = `in_sample' &
		!missing(L5_d_dine_in_ban, L4_d_dine_in_ban, L3_d_dine_in_ban, L2_d_dine_in_ban, L1_d_dine_in_ban,
			d_dine_in_ban,
			F1_d_dine_in_ban, F2_d_dine_in_ban, F3_d_dine_in_ban, F4_d_dine_in_ban, F5_d_dine_in_ban,
			L5_d_school_closure, L4_d_school_closure, L3_d_school_closure, L2_d_school_closure, L1_d_school_closure,
			d_school_closure,
			F1_d_school_closure, F2_d_school_closure, F3_d_school_closure, F4_d_school_closure, F5_d_school_closure,
			L5_d_non_essential_closure, L4_d_non_essential_closure, L3_d_non_essential_closure, L2_d_non_essential_closure, L1_d_non_essential_closure,
			d_non_essential_closure,
			F1_d_non_essential_closure, F2_d_non_essential_closure, F3_d_non_essential_closure, F4_d_non_essential_closure, F5_d_non_essential_closure,
			L5_d_shelter_in_place, F2_d_shelter_in_place, F3_d_shelter_in_place, F4_d_shelter_in_place, F5_d_shelter_in_place,
			d_shelter_in_place,
			L5_d_shelter_in_place, L4_d_shelter_in_place, L3_d_shelter_in_place, L2_d_shelter_in_place, L1_d_shelter_in_place,
			`cases', `depvar');
	
	local pvars L5_d_dine_in_ban L4_d_dine_in_ban L3_d_dine_in_ban L2_d_dine_in_ban L1_d_dine_in_ban
			d_dine_in_ban
			F1_d_dine_in_ban F2_d_dine_in_ban F3_d_dine_in_ban F4_d_dine_in_ban F5_d_dine_in_ban
			L5_d_school_closure L4_d_school_closure L3_d_school_closure L2_d_school_closure L1_d_school_closure
			d_school_closure
			F1_d_school_closure F2_d_school_closure F3_d_school_closure F4_d_school_closure F5_d_school_closure
			L5_d_non_essential_closure L4_d_non_essential_closure L3_d_non_essential_closure L2_d_non_essential_closure L1_d_non_essential_closure
			d_non_essential_closure
			F1_d_non_essential_closure F2_d_non_essential_closure F3_d_non_essential_closure F4_d_non_essential_closure F5_d_non_essential_closure
			L5_d_shelter_in_place L4_d_shelter_in_place L3_d_shelter_in_place L2_d_shelter_in_place L1_d_shelter_in_place
			d_shelter_in_place
			F1_d_shelter_in_place F2_d_shelter_in_place F3_d_shelter_in_place F4_d_shelter_in_place F5_d_shelter_in_place;
	#delimit cr

	local linear xb: `pvars'
	nl (`depvar' = `cases_expr' + {`linear'}) if nl_sample, vce(cluster stateid) noconstant
	drop nl_sample
}

* Show results
estimates

// esttab, coeflabels(b0: "Cases pc, coeff" b1: "Cases pc, power")
