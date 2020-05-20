/*
Non-linear least squares estimation on county-level mobility data
*/

clear
do "stats/code/prepare_counties_data.do"

* Set experiment
local experiment 3

* First differences
local FD FD_

* Macros
#delimit ;
local pvars `FD'd_dine_in_ban `FD'd_school_closure `FD'd_non_essential_closure
	`FD'd_shelter_in_place;

local plags `FD'Ld_dine_in_ban `FD'Ld_school_closure `FD'Ld_non_essential_closure `FD'Ld_shelter_in_place;

local pleads `FD'Fd_dine_in_ban `FD'Fd_school_closure `FD'Fd_non_essential_closure `FD'Fd_shelter_in_place;

if "`FD'" == "FD_" {;
	capture gen FD_adj_cases90 = D.adj_cases90;
	replace FD_adj_cases90 = 0 if FD_adj_cases90 < 0;
};
local cases_expr {b0=-1} * `FD'adj_cases90 ^ {b1=0.25};
#delimit cr


* Benchmark
if `experiment' == 1 {
	#delimit ;
	gen nl_sample = restr_sample &
		!missing(`FD'd_dine_in_ban, `FD'd_school_closure,
			`FD'd_non_essential_closure, `FD'd_shelter_in_place,
			`FD'adj_cases90, `FD'mobility_work);
	#delimit cr

	local linear xb: `pvars'
	nl (mobility_work = `cases_expr' + {`linear'}) if nl_sample, vce(cluster stateid) noconstant
	drop nl_sample
}

* Leads and lags
if `experiment' == 2 {
	#delimit ;
	gen nl_sample = restr_sample &
		!missing(d_dine_in_ban, d_school_closure,
			d_non_essential_closure, d_shelter_in_place,
			Ld_dine_in_ban, Ld_school_closure,
			Fd_dine_in_ban, Fd_school_closure, Ld_shelter_in_place,
			Ld_non_essential_closure, Fd_non_essential_closure,
			Fd_shelter_in_place,
			adj_cases90, mobility_work);
	#delimit cr

	local linear xb: `pvars' `pleads' `plags'
	nl (mobility_work = `cases_expr' + {`linear'}) if nl_sample, vce(cluster stateid) noconstant
	drop nl_sample
}

* Population-weighted
if `experiment' == 3 {
	capture drop wgts
	capture drop nl_sample
	gen wgts = population / 10000
	
	#delimit ;
	gen nl_sample = restr_sample &
		!missing(`FD'd_dine_in_ban, `FD'd_school_closure,
			`FD'd_non_essential_closure, `FD'd_shelter_in_place,
			`FD'adj_cases90, `FD'mobility_work, wgts, population);
	#delimit cr

	local linear xb: `pvars'
	nl (mobility_work = `cases_expr' + {`linear'}) [aw=wgts] if nl_sample, robust noconstant

	drop wgts nl_sample
}

* Weighted, leads and lags
if `experiment' == 4 {
	gen wgts = population / 10000

	#delimit ;
	gen nl_sample = restr_sample &
		!missing(d_dine_in_ban, d_school_closure,
			d_non_essential_closure, d_shelter_in_place,
			Ld_dine_in_ban, Ld_school_closure,
			Fd_dine_in_ban, Fd_school_closure, Ld_shelter_in_place
			Ld_non_essential_closure, Fd_non_essential_closure,
			Fd_shelter_in_place, wgts,
			adj_cases90, mobility_work);
	#delimit cr

	local linear xb: `pvars' `pleads' `plags'
	nl (mobility_work = `cases_expr' + {`linear'}) [iw=wgts] if nl_sample, robust noconstant
	drop wgts nl_sample
}

* State-specific fixed effect
if `experiment' == 5 {
	capture drop nl_sample
	capture drop d_state*

	tab stateid, gen(d_state)

	#delimit ;
	gen nl_sample = restr_sample &
		!missing(d_dine_in_ban, d_school_closure,
			d_non_essential_closure, d_shelter_in_place,
			adj_cases90, mobility_work);
	#delimit cr

	local linear xb: `pvars' d_state*
	nl (mobility_work = `cases_expr' + {`linear'}) if nl_sample, vce(cluster stateid) noconstant
	drop nl_sample d_state*
}

* State-specific coefficients on policies
if `experiment' == 6 {
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
	gen nl_sample = restr_sample &
		!missing(d_dine_in_ban, d_school_closure,
			d_non_essential_closure, d_shelter_in_place,
			adj_cases90, mobility_work);
	#delimit cr

	local linear xb: `pvars' `stmacro'
	nl (mobility_work = `cases_expr' + {`linear'}) if nl_sample, vce(cluster stateid) noconstant
	drop nl_sample d_state* state*_d_*
}

* State-specific fixed effects and coefficients on policies
if `experiment' == 7 {
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
	gen nl_sample = restr_sample &
		!missing(d_dine_in_ban, d_school_closure,
			d_non_essential_closure, d_shelter_in_place,
			adj_cases90, mobility_work);
	#delimit cr

	local linear xb: `pvars' `stmacro' d_state*
	nl (mobility_work = `cases_expr' + {`linear'}) if nl_sample, vce(cluster stateid) noconstant
	drop nl_sample d_state* state*_d_*
}

* With state-specific 3/13 dummy
if `experiment' == 8 {
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
	gen nl_sample = restr_sample &
		!missing(d_dine_in_ban, d_school_closure,
			d_non_essential_closure, d_shelter_in_place,
			adj_cases90, mobility_work);
	#delimit cr

	local linear xb: `pvars' state*_march13
	nl (mobility_work = `cases_expr' + {`linear'}) if nl_sample, vce(cluster stateid) noconstant
	drop nl_sample d_state*
}

* New cases instead of total
if `experiment' == 9 {
	capture drop nl_sample
	capture drop new_cases
	gen new_cases = D.cases
	replace new_cases = 0 if new_cases < 0
	
	#delimit ;
	gen nl_sample = restr_sample &
		!missing(d_dine_in_ban, d_school_closure,
			d_non_essential_closure, d_shelter_in_place,
			new_cases, mobility_work);
	#delimit cr

	local cases_expr {b0=-1} * new_cases ^ {b1=0.25}
	local linear xb: `pvars'
	nl (mobility_work = `cases_expr' + {`linear'}) if nl_sample, vce(cluster stateid) noconstant
	drop nl_sample
}

* New cases, weighted
if `experiment' == 10 {
	capture drop wgts
	capture drop nl_sample
	capture drop new_cases

	gen new_cases = D.cases
	gen wgts = population / 10000

	replace new_cases = 0 if new_cases < 0
	
	#delimit ;
	gen nl_sample = restr_sample &
		!missing(d_dine_in_ban, d_school_closure,
			d_non_essential_closure, d_shelter_in_place,
			new_cases, mobility_work);
	#delimit cr

	local cases_expr {b0=-1} * new_cases ^ {b1=0.25}
	local linear xb: `pvars'
	nl (mobility_work = `cases_expr' + {`linear'}) [iw=wgts] if nl_sample, robust noconstant
	drop nl_sample
}

* First differences
if `experiment' == 11 {
	capture drop nl_sample
	capture drop dcases
	#delimit ;
	gen nl_sample = restr_sample &
		!missing(d_dine_in_ban, d_school_closure,
			d_non_essential_closure, d_shelter_in_place,
			adj_cases90, mobility_work);
	#delimit cr

	local linear xb: `pvars'
	nl (mobility_work = `cases_expr' + {`linear'}) if nl_sample, vce(cluster stateid) noconstant
	drop nl_sample
}

esttab, coeflabels(b0: "Cases pc, coeff" b1: "Cases pc, power")
