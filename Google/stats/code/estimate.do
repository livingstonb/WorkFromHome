/* --- HEADER ---
Performs OLS estimation of mobility regressions.
*/

estimates clear

* Read and prepare dataset
use `#PREREQ' "build/output/mobility_cleaned.dta", clear
`#PREREQ' do "stats/code/pre_estimation.do"

* Declare panel
tsset stateid date

* Common dummy variables
local days_of_week d_saturday d_sunday d_monday

local idummies d_stay_at_home d_school_closure d_dine_in_ban d_business_closure

local interventions
foreach dum of local idummies {
	local interventions `interventions' L.`dum' `dum' F.`dum'
}

* Estimation
gen dretail = D.mobility_retail
label variable dretail "Retail"

gen dwork = D.mobility_work
label variable dwork "Work"

drop if !all_interventions

local names retail work
foreach var of local names {
	eststo: reg d`var' `days_of_week' `interventions', robust

	gen const_`var' = (days_retail - 1) * _b[_cons] if !missing(stay_at_home)

	gen tmp1_`var' = _b[d_saturday] * d_saturday + _b[d_sunday] * d_sunday + _b[d_monday] * d_monday
	bysort stateid: egen tmp2_`var' = total(tmp1_`var') if !missing(stay_at_home) & !missing(d`var')
	replace tmp2_`var' = tmp2_`var' + const_`var'
	bysort stateid: egen explained_`var' = max(tmp2_`var')
	drop tmp1_`var' tmp2_`var'
	
	label variable const_`var' "beta * T, `var'"
	label variable explained_`var' "Voluntary, `var'"
}

* Create regression table
`#TARGET' esttab using "stats/output/reg_table.tex", label replace

* Table of changes, by state
duplicates drop statename, force
keep statename explained* total_change*
label variable total_change_retail "Total, retail"
label variable total_change_work "Total, work"
label variable statename "State"

#delimit ;
`#TARGET' export excel statename explained* total*
	using "stats/output/mobility_changes.xlsx",
	replace firstrow(varlabels);
#delimit cr
