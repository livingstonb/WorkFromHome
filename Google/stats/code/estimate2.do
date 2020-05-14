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

* Policy dummies
gen d_dine_in_ban = (date == dine_in_ban)
gen d_shelter_in_place = (date == shelter_in_place)
gen d_non_essential_closure = (date == non_essential_closure)

#delimit ;
reg d.mobility_work
	d.cases
	d_dine_in_ban d_shelter_in_place d_non_essential_closure
	i.stateid#day_of_week
	if before_shelter_in_place, robust;
#delimit cr
// reg d.mobility_rr l.cases i.stateid if before_stay_at_home, robust

* Predict
predict fitted if before_shelter_in_place, xb

gen dmob = d.mobility_work
do "stats/code/compute_state_R2.do" R2 dmob fitted before_shelter_in_place

* Plot fitted vs actual
twoway line 

// bysort stateid: egen meany = mean(dmob) if before_shelter_in_place
//
// gen tot_sq = (dmob - meany) ^ 2 if before_shelter_in_place
// gen res_sq = (dmob - fitted) ^ 2 if before_shelter_in_place
//
// collapse (sum) tot_sq (sum) res_sq, by(stateid)
// gen R2 = 1 - res_sq / tot_sq
// keep stateid R2
