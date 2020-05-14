/* --- HEADER ---
Performs OLS estimation of mobility regressions.
*/

estimates clear
adopath + "../ado"

* Read
use "build/output/cleaned_final.dta", clear
drop if statename == "District of Columbia"

* Declare panel
tsset stateid date

* Set final date for each state
gen before_shelter_in_place = (date <= shelter_in_place) if !missing(shelter_in_place)
quietly sum shelter_in_place

gen in_sample = before_shelter_in_place
replace in_sample = 0 if missing(shelter_in_place)
replace in_sample = 1 if (date <= `r(max)') & missing(shelter_in_place)

* Use dates after President's day
replace in_sample = 0 if date < date("2020-02-24", "YMD")

keep if in_sample
drop before_shelter_in_place in_sample

* Check for invalid daily infections
gen neg_cases = (d.cases < 0)
gen neg_deaths = (d.deaths < 0)

by stateid: egen invalid_cases = max(neg_cases)
by stateid: egen invalid_deaths = max(neg_deaths)

drop if invalid_cases
drop invalid_cases invalid_deaths

* New variables
gen day_of_week = dow(date)

label define day_of_week_lbl 0 "Sunday" 1 "Monday" 2 "Tuesday" 3 "Wednesday"
label define day_of_week_lbl 4 "Thursday" 5 "Friday" 6 "Saturday", add
label values day_of_week day_of_week_lbl

* Policy dummies
gen d_school_closure = (date == school_closure)
gen d_dine_in_ban = (date == dine_in_ban)
gen d_shelter_in_place = (date == shelter_in_place)
gen d_non_essential_closure = (date == non_essential_closure)

label variable d_school_closure "Shool closure"
label variable d_dine_in_ban "Dine-in ban"
label variable d_shelter_in_place "Shelter-in-place order"
label variable d_non_essential_closure "Non-essential services closure"

gen dmobility_work = d.mobility_work
label variable dmobility_work "Change in mobility, workplaces"

gen dmobility_rr = d.mobility_rr
label variable dmobility_rr "Change in mobility, retail and rec"

local mobvars work rr

foreach suffix of local mobvars {
	#delimit ;
	eststo REG_`suffix': reg dmobility_`suffix'
		d.cases
		d_school_closure d_dine_in_ban d_shelter_in_place d_non_essential_closure
		i.stateid#day_of_week
		, robust noconstant;
	#delimit cr
	
	predict fitted_change_`suffix', xb
}

#delimit ;
esttab REG_work REG_rr using "stats/output/mobility_regressions.tex", 
		replace label nonumbers compress booktabs wide
		keep(D.cases d_school_closure d_dine_in_ban d_shelter_in_place d_non_essential_closure)
		r2 ar2 scalars(N);
#delimit cr

* Predict
do "stats/code/compute_state_R2.do" R2 dmobility_work fitted_change_work

* Generated fitted levels
gen tmp_levels = fitted_change_work
replace tmp_levels = mobility_work if date == date("2020-02-24", "YMD")
bysort stateid (date): gen fitted_mobility_work = sum(tmp_levels)
label variable fitted_mobility_work "Fitted mobility, workplaces"

* Order states by number of infections
bysort stateid (date): gen state_cases = cases[_N] - cases[1]
egen rank_cases = rank(state_cases) if date == date("2020-02-24", "YMD")

levelsof statename if inlist(rank_cases, 1, 2, 3, 48, 49, 50) & !missing(rank_cases), local(ranked)

* Plot fitted vs actual
label variable mobility_work "Mobility, workplaces"

foreach state of local ranked {
	quietly sum state_cases if statename == "`state'"
	local num_cases = `r(max)'

	#delimit ;
	twoway line mobility_work date if statename == "`state'"
		|| line fitted_mobility_work date if statename == "`state'",
		graphregion(color(gs16)) title("`state', cases per 10,000 = `num_cases'");
	#delimit cr
	
	capture mkdir "stats/output/figs"
	graph export "stats/output/figs/`state'_model_fit.png", replace
	graph close
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
