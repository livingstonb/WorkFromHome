
* Read
use "build/temp/cleaned_mobility.dta", clear
label variable mobility_rr "Mobility, retail and rec"
label variable mobility_work "Mobility, workplaces"

* Merge with NPIS data
merge m:1 state using "build/temp/cleaned_npis.dta", nogen keep(1 3)
drop shelter_in_place

* Merge with my dataset
merge m:1 state using "build/temp/stay_at_home.dta", nogen keep (1 3)
rename stay_at_home shelter_in_place

* Merge with dine-in-bans
merge m:1 state using "build/temp/dine_in_bans.dta", nogen

* Merge with COVID cases
merge m:1 state date using "build/temp/covid_deaths.dta", nogen keep(1 3)
replace cases = 0 if missing(cases)
replace deaths = 0 if missing(deaths)

* Merge with populations
merge m:1 state using "build/temp/populations.dta", nogen


rename state statename
encode statename, gen(stateid)

drop if statename == "District of Columbia"
bysort date: egen agg_cases = total(cases)
bysort date: egen agg_pop = total(population)
replace agg_cases = agg_cases / agg_pop
drop agg_pop

replace cases = cases / population
replace deaths = deaths / population

label variable cases "Cases per person"
label variable deaths "Deaths per person"

* Change mobility definition
replace mobility_work = log(1 + mobility_work / 100)
replace mobility_rr = log(1 + mobility_rr / 100)

label variable mobility_work "Log mobility, workplaces"
label variable mobility_rr "Log mobility, retail and rec"

* Create recovery-adjusted cases
tsset stateid date

rename cases tmp_cases
rename agg_cases tmp_agg_cases
gen cases = tmp_cases - 0.1 * L.tmp_cases
gen agg_cases = tmp_agg_cases - 0.1 * L.tmp_agg_cases
drop tmp_*

* Linear time trend
tsset stateid date
by stateid: gen ndays = _n - 1
label variable ndays "Number of days after 2/24"

* Policy dummies
gen d_shelter_in_place = (date >= shelter_in_place) & !missing(shelter_in_place)
gen d_school_closure = (date >= school_closure) & !missing(school_closure)
gen d_dine_in_ban = (date >= dine_in_ban) & !missing(dine_in_ban)
gen d_non_essential_closure = (date >= non_essential_closure) & !missing(non_essential_closure)

label variable d_school_closure "School closure"
label variable d_dine_in_ban "Dine-in ban"
label variable d_shelter_in_place "Shelter-in-place order"
label variable d_non_essential_closure "Non-essential services closure"

save "build/output/cleaned_final.dta", replace
