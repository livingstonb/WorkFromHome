/* --- HEADER ---
Performs OLS estimation of mobility regressions.
*/

estimates clear
adopath + "../ado"

* Read
use "build/output/cleaned_final.dta", clear

* Declare panel
tsset stateid date

* Drop some states
gen neg_cases = (d.cases < 0)
gen neg_deaths = (d.deaths < 0)

by stateid: egen invalid_cases = max(neg_cases)
by stateid: egen invalid_deaths = max(neg_deaths)

drop if statename == "District of Columbia"

// egen excluded = tag(stateid) if invalid_deaths | missing(shelter_in_place)
drop if invalid_cases | missing(shelter_in_place)

* Use dates after President's day
keep if date >= date("2020-02-24", "YMD")

* New variables
gen before_shelter_in_place = (date <= shelter_in_place)
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

#delimit ;
reg d.mobility_work
	d.cases
	d_school_closure d_dine_in_ban d_shelter_in_place d_non_essential_closure
	i.stateid#day_of_week
	if before_shelter_in_place, robust;
	
esttab using "stats/output/mobility_regressions.tex", 
	replace label nonumbers compress booktabs wide
	keep(D.cases d_school_closure d_dine_in_ban d_shelter_in_place d_non_essential_closure _cons)
	r2 ar2 scalars(N);
#delimit cr

* Predict
predict fitted_change if before_shelter_in_place, xb

gen dmob = d.mobility_work
label variable dmob "Change in mobility, workplaces"

do "stats/code/compute_state_R2.do" R2 dmob fitted_change before_shelter_in_place

* Generated fitted levels
gen tmp_levels = fitted_change
replace tmp_levels = mobility_work if date == date("2020-02-24", "YMD")
bysort stateid (date): gen fitted_mobility = sum(tmp_levels)
label variable fitted_mobility "Fitted mobility, workplaces"

* Plot fitted vs actual
label variable mobility_work "Mobility, workplaces"

local states Nevada Montana Wyoming California Washington Tennessee Alaska Alabama

foreach state of local states {
	quietly sum R2 if statename == "`state'"
	local R2 = `r(max)'

	#delimit ;
	twoway line mobility_work date if statename == "`state'" & before_shelter_in_place
		|| line fitted_mobility date if statename == "`state'" & before_shelter_in_place,
		graphregion(color(gs16)) title("`state', R2 = `R2'");
	#delimit cr
	
	capture mkdir "stats/output/figs"
	graph export "stats/output/figs/`state'_model_fit.png", replace
	graph close
}

// bysort stateid: egen meany = mean(dmob) if before_shelter_in_place
//
// gen tot_sq = (dmob - meany) ^ 2 if before_shelter_in_place
// gen res_sq = (dmob - fitted) ^ 2 if before_shelter_in_place
//
// collapse (sum) tot_sq (sum) res_sq, by(stateid)
// gen R2 = 1 - res_sq / tot_sq
// keep stateid R2
