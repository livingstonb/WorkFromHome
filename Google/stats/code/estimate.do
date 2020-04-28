
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
eststo: quietly reg D.mobility_retail `days_of_week' `interventions', robust
gen benchmark_change_retail = (days_retail - 1) * _b[_cons] if !missing(stay_at_home)

eststo: quietly reg D.mobility_work `days_of_week' `interventions', robust
gen benchmark_change_work = (days_work - 1) * _b[_cons] if !missing(stay_at_home)

* Create table
`#TARGET' esttab using "stats/output/reg_table.tex", label replace

* Table of benchmark change
#delimit ;
collapse (firstnm) benchmark_change_retail
	(firstnm) benchmark_change_work
	(firstnm) total_change_retail
	(firstnm) total_change_work, by(statename);
#delimit cr
label variable benchmark_change_retail "T * Constant, retail"
label variable benchmark_change_work "T * Constant, work"
label variable total_change_retail "Total, retail"
label variable total_change_work "Total, work"
label variable statename "State"

#delimit ;
`#TARGET' export excel using "stats/output/mobility_changes.xlsx",
	replace firstrow(varlabels);
#delimit cr
