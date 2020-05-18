/*
Performs OLS estimation of mobility regressions.
*/

estimates clear
adopath + "../ado"

* Read
use "build/output/cleaned_states.dta", clear

* Declare panel
tsset stateid date

gen sqrt_cases = cases ^ (1/4)
label variable sqrt_cases "Sqrt state cases per person"

gen sqrt_natl_cases = natl_cases ^ (1/4)

gen exp_cases = F7.cases
// replace exp_cases = 0 if date < date("2020-03-13", "YMD")

gen sq_exp_cases = exp_cases ^ 2

* Growth rate, extrapolated backward to first case
tsset stateid date
gen raw_gcases = (cases - L.cases) / L.cases if L.cases > 0
replace raw_gcases = 0 if (cases == 0) & (L.cases == 0)

moving_average raw_gcases, time(date) panelid(stateid) gen(gcases) nperiods(5)
replace gcases = 0 if raw_gcases == 0

* Set period of sample
keep if date >= date("2020-02-24", "YMD")

local final_date // "2020-04-15"

if "`final_date'" == "" {
	gen restr_sample = (date <= shelter_in_place) if !missing(shelter_in_place)

	quietly sum shelter_in_place
	replace restr_sample = 0 if missing(shelter_in_place)
	replace restr_sample = 1 if (date <= `r(max)') & missing(shelter_in_place)
}
else {
	gen restr_sample =  (date <= date("`final_date'", "YMD"))
}


by stateid: gen tstate = _N
label variable tstate "Number of observations for state"

gen wgt = population / (tstate * 1000)

* Average growth rate
gen lcases = log(cases) if d_march13
levelsof stateid, local(stateids)

gen growth = .
foreach sid of local stateids {
	quietly reg lcases ndays if stateid == `sid'
	replace growth = _b[ndays] if stateid == `sid'
}
replace growth = 0 if !d_march13

* Lead and lags of policies
gen Ld_school_closure = LD.d_school_closure
gen Fd_school_closure = FD.d_school_closure
gen Ld_dine_in_ban = LD.d_dine_in_ban
gen Fd_dine_in_ban = FD.d_dine_in_ban
gen Fd_shelter_in_place = FD.d_shelter_in_place
gen Ld_non_essential_closure = LD.d_non_essential_closure
gen Fd_non_essential_closure = FD.d_non_essential_closure

replace Ld_school_closure = 0 if missing(Ld_school_closure)
replace Fd_school_closure = 0 if missing(Fd_school_closure)
replace Ld_dine_in_ban = 0 if missing(Ld_dine_in_ban)
replace Fd_dine_in_ban = 0 if missing(Fd_dine_in_ban)
replace Fd_shelter_in_place = 0 if missing(Fd_shelter_in_place)
replace Ld_non_essential_closure = 0 if missing(Ld_non_essential_closure)
replace Fd_non_essential_closure = 0 if missing(Fd_non_essential_closure)

* Walkthrough of model specifications
// do "stats/code/est_alt_specifications.do"

* Loop over regression models
replace restr_sample = 0 if weekend
do "stats/code/make_regression_tables.do" make_plots

//
// * Manual reg models
// estimates clear
// eststo: reg mobility_work cases d_school_closure d_dine_in_ban
// 		d_non_essential_closure d_shelter_in_place, noconstant vce(cluster stateid);
//
// eststo EST`estnum': reg `depvar'
// 		`varcases'
// 		`policyvars'
// 		`sample_macro'
// 		`wgt_macro', vce(cluster stateid);







* Peak cases nationally
sum natl_cases

* Peak cases by state
collapse (max) cases (firstnm) population, by(stateid)

bysort stateid: egen peak_cases_states = max(cases)





* Plot all mobility values
#delimit ;
xtline mobility_rr, graphregion(color(gs16)) ytitle("")
	title("Log mobility by state");
#delimit cr























