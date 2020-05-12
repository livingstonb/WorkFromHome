/* --- HEADER ---
Performs OLS estimation of mobility regressions.
*/

estimates clear

* Read and prepare dataset
use "build/output/mobility_cleaned.dta", clear
rename state statename
encode statename, gen(stateid)

order stateid date

rename retail_and_recreation_percent_ch mobility_rr
rename workplaces_percent_change_from_b mobility_work

* Declare panel
tsset stateid date

* Flows: cases and deaths
gen cases = d.cum_cases
gen deaths = d.cum_deaths

gen neg_cases = (cases < 0)
gen neg_deaths = (deaths < 0)

by stateid: egen invalid_cases = max(neg_cases)
by stateid: egen invalid_deaths = max(neg_deaths)

drop if invalid_cases | invalid_deaths

* New variables
gen before_stay_at_home = (date < stay_at_home) if !missing(stay_at_home)

tab stateid, gen(dstate)

reg mobility_rr l.deaths if before_stay_at_home, robust
reg mobility_rr l.deaths dstate if before_stay_at_home, robust
