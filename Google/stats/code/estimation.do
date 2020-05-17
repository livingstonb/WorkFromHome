/*
Performs OLS estimation of mobility regressions.
*/

estimates clear
adopath + "../ado"

* Read
use "build/output/cleaned_final.dta", clear

* Declare panel
tsset stateid date

* Use moving average of cases
rename cases raw_cases
moving_average raw_cases, time(date) panelid(stateid) gen(cases) nperiods(3)
label variable cases "State cases per person"

rename agg_cases raw_natl_cases
moving_average raw_natl_cases, time(date) panelid(stateid) gen(natl_cases) nperiods(3)
label variable natl_cases "US cases per person"

gen sq_cases = (cases - 0.02) ^ 2
label variable sq_cases "Sq state cases per person"

gen sq_natl_cases = natl_cases ^ 2
label variable sq_natl_cases "Sq US cases per person"

gen exp_cases = F7.cases
replace exp_cases = 0 if date < date("2020-03-13", "YMD")

gen sq_exp_cases = exp_cases ^ 2

* Set period of sample
keep if date >= date("2020-02-24", "YMD")

local final_date // "2020-04-15"

if "`final_date'" == "" {
	gen before_shelter_in_place = (date <= shelter_in_place) if !missing(shelter_in_place)

	quietly sum shelter_in_place
	gen in_sample = before_shelter_in_place
	replace in_sample = 0 if missing(shelter_in_place)
	replace in_sample = 1 if (date <= `r(max)') & missing(shelter_in_place)
	keep if in_sample
	drop before_shelter_in_place in_sample
}
else {
	keep if (date <= date("`final_date'", "YMD"))
}


by stateid: gen tstate = _N
label variable tstate "Number of observations for state"

gen wgt = population / (tstate * 1000)

* March 13 dummy
gen d_march13 = date >= date("2020-03-13", "YMD")
label variable d_march13 "March 13th or later"

* Day-of-week dummies
gen day_of_week = dow(date)

label define day_of_week_lbl 0 "Sunday" 1 "Monday" 2 "Tuesday" 3 "Wednesday"
label define day_of_week_lbl 4 "Thursday" 5 "Friday" 6 "Saturday", add
label values day_of_week day_of_week_lbl

gen weekend = inlist(day_of_week, 0, 6)

* Day-of-week and period interaction
tab day_of_week, gen(d_day)

forvalues i = 0/6 {
	gen d_period1_day`i' = (day_of_week == `i') & !d_march13
	gen d_period2_day`i' = (day_of_week == `i') & d_march13
}

* Loop over regression models
keep if !weekend
do "stats/code/make_regression_tables.do"










* Peak cases nationally
sum natl_cases

* Peak cases by state
collapse (max) cases (firstnm) population, by(stateid)

bysort stateid: egen peak_cases_states = max(cases)





* Plot all mobility values
#delimit ;
xtline mobility_work, overlay graphregion(color(gs16)) ytitle("")
	title("Log mobility by state");
#delimit cr


// * Plot fitted vs actual for states with few/many infections
// label variable mobility_work "Mobility, workplaces"
// label variable mobility_rr "Mobility, retail and rec"
//
// local mobvars work rr
// foreach suffix of local mobvars {
// foreach state of local ranked {
// 	quietly sum state_cases if statename == "`state'"
// 	local num_cases = `r(max)'
//
// 	#delimit ;
// 	twoway line mobility_`suffix' date if statename == "`state'"
// 		|| line fitted_mobility_`suffix' date if statename == "`state'",
// 		graphregion(color(gs16)) title("`state', cases per person = `num_cases'");
// 	#delimit cr
//	
// 	capture mkdir "stats/output/fitted_vs_actual_`suffix'"
// 	graph export "stats/output/fitted_vs_actual_`suffix'/`state'_model_fit.png", replace
// 	graph close
// }
// }






























* Summary statistics for state cases

foreach suffix of local mobvars {
	#delimit ;
	eststo REG_`suffix': reg mobility_`suffix'
		cases sq_cases agg_cases sq_agg_cases
		d_school_closure d_dine_in_ban d_shelter_in_place d_non_essential_closure
		i.stateid#day_of_week
		, robust noconstant;
	#delimit cr
	
// 	gen effect_cases_`suffix' = _b[dcases] * dcases
// 	label variable effect_cases_`suffix' "Estimated effect of new cases"
//	
// 	predict fitted_change_`suffix', xb
// 	gen rhs_nocases_`suffix' = fitted_change_`suffix' - effect_cases_`suffix'
// 	label variable rhs_nocases_`suffix' "Fitted value less the effect of new cases"
//	
// 	gen cases_with_resid_`suffix' = dmobility_`suffix' - rhs_nocases_`suffix'
// 	label variable cases_with_resid_`suffix' "New cases effect plus residual"
//	
// 	* R2 by state
// 	do "stats/code/compute_state_R2.do" R2_`suffix' dmobility_`suffix' fitted_change_`suffix'
//
// 	* Generated fitted levels
// 	gen tmp_levels = fitted_change_`suffix'
// 	replace tmp_levels = mobility_`suffix' if date == date("2020-02-24", "YMD")
// 	bysort stateid (date): gen fitted_mobility_`suffix' = sum(tmp_levels)
// 	drop tmp_levels
}
// label variable fitted_mobility_work "Fitted mobility, workplaces"
// label variable fitted_mobility_rr "Fitted mobility, retail and rec"

#delimit ;
esttab REG_work REG_rr using "stats/output/mobility_regressions.tex", 
		replace label nonumbers compress booktabs
		keep(cases sq_cases agg_cases sq_agg_cases
		d_school_closure d_dine_in_ban d_shelter_in_place d_non_essential_closure)
		r2 ar2 scalars(N);
#delimit cr

* Order states by number of infections
bysort stateid (date): gen state_cases = cases[_N] - cases[1]
egen rank_cases = rank(state_cases) if date == date("2020-02-24", "YMD")

levelsof statename if inlist(rank_cases, 1, 2, 3, 48, 49, 50) & !missing(rank_cases), local(ranked)

* Plot fitted vs actual for states with few/many infections
label variable mobility_work "Mobility, workplaces"
label variable mobility_rr "Mobility, retail and rec"

local mobvars work rr
foreach suffix of local mobvars {
foreach state of local ranked {
	quietly sum state_cases if statename == "`state'"
	local num_cases = `r(max)'

	#delimit ;
	twoway line mobility_`suffix' date if statename == "`state'"
		|| line fitted_mobility_`suffix' date if statename == "`state'",
		graphregion(color(gs16)) title("`state', cases per 10,000 = `num_cases'");
	#delimit cr
	
	capture mkdir "stats/output/fitted_vs_actual_`suffix'"
	graph export "stats/output/fitted_vs_actual_`suffix'/`state'_model_fit.png", replace
	graph close
}
}

* Plot \Delta I_t^s vs \Delta x_t^s - \hat{\beta}_d^s W_{dt} - \hat{\gamma}_j P_{jt}^s
label variable cases_with_resid_work "Mobility change less est effect of day and policy dummies"
label variable cases_with_resid_rr "Mobility change less est effect of day and policy dummies"

levelsof statename, local(states)
local mobvars work rr
foreach suffix of local mobvars {
foreach state of local states {
	if "`suffix'" == "work" {
		local figtitle "`state', workplaces"
	}
	else {
		local figtitle "`state', retail and recreation"
	}
	#delimit ;
	twoway scatter cases_with_resid_`suffix' dcases if statename == "`state'",
		graphregion(color(gs16)) title("`figtitle'");
	#delimit cr
	
	capture mkdir "stats/output/figs_residuals_new_cases"
	graph export "stats/output/figs_residuals_new_cases/`state'_`suffix'.png", replace
}

local mobvars work rr

forvalues restricted = 0/1 {
foreach suffix of local mobvars {
	local zoomed = cond(`restricted', "ZOOMED", "")
	if "`suffix'" == "work" {
		local figtitle "All states, workplaces `zoomed'"
	}
	else {
		local figtitle "All states, retail and recreation `zoomed'"
	}
	
	if `restricted' {
		#delimit ;
		twoway scatter cases_with_resid_`suffix' dcases if inrange(dcases, 0, 1) & inrange(cases_with_resid_`suffix', -10, 10),
			graphregion(color(gs16)) title("`figtitle'");
		#delimit cr
	}
	else {
		#delimit ;
		twoway scatter cases_with_resid_`suffix' dcases,
			graphregion(color(gs16)) title("`figtitle'");
		#delimit cr
	}
	
	capture mkdir "stats/output/figs_residuals_new_cases"
	graph export "stats/output/figs_residuals_new_cases/all_`suffix'_`zoomed'.png", replace
}
}

// local states Nevada Montana Wyoming California Washington Tennessee Alaska Alabama

// foreach state of local states {
// 	quietly sum R2 if statename == "`state'"
// 	local R2 = `r(max)'
//
// 	#delimit ;
// 	twoway line mobility_work date if statename == "`state'"
// 		|| line fitted_mobility date if statename == "`state'",
// 		graphregion(color(gs16)) title("`state', R2 = `R2'");
// 	#delimit cr
//	
// 	capture mkdir "stats/output/figs"
// 	graph export "stats/output/figs/`state'_model_fit.png", replace
// 	graph close
// }

// bysort stateid: egen meany = mean(dmob) if before_shelter_in_place
//
// gen tot_sq = (dmob - meany) ^ 2 if before_shelter_in_place
// gen res_sq = (dmob - fitted) ^ 2 if before_shelter_in_place
//
// collapse (sum) tot_sq (sum) res_sq, by(stateid)
// gen R2 = 1 - res_sq / tot_sq
// keep stateid R2
