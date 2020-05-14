
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
replace cases = 10000 * cases / population
replace deaths = 10000 * deaths / population

label variable cases "Infections per 10,000 people"
label variable deaths "Deaths per 10,000 people"

* Declare panel
rename state statename
encode statename, gen(stateid)

save "build/output/cleaned_final.dta", replace
