*Read
clear all
use "build/temp/merged_global.dta"

* Transform mobility
replace mobility_rr = log(1 + mobility_rr / 100)
replace mobility_work = log(1 + mobility_work / 100)

label variable mobility_rr "Log mobility, retail and recreation"
label variable mobility_work "Log mobility, workplaces"

* Renaming
rename c1_schoolclosing d_school_closure
rename c1_flag f_school_closure

rename c2_workplaceclosing d_work_closure
rename c2_flag f_work_closure

rename c3_cancelpublicevents d_cancel_public_events
rename c3_flag f_cancel_public_events

rename c4_restrictionsongatherings d_gathering_restriction
rename c4_flag f_gathering_restriction

rename c5_closepublictransport d_transport_closure
rename c5_flag f_transport_closure

rename c6_stayathomerequirements d_stay_at_home
rename c6_flag f_stay_at_home

rename c7_restrictionsoninternalmovemen d_movement_restrictions
rename c7_flag f_movement_restrictions

drop stringencyindexfordisplay stringencylegacy*
rename stringencyindex stringency

* Transform indexes
replace stringency = stringency / 100

* Get cases & deaths per capita
gen active_cases = (cases - recoveries - deaths) / population

rename confirmedcases oxf_cases
rename confirmeddeaths oxf_deaths
replace cases = cases / population
replace deaths = deaths / population
replace oxf_cases = oxf_cases / population
replace oxf_deaths = oxf_deaths / population
drop if missing(population)

* Weights
gen wgts = population / 10000

save "build/output/cleaned_global.dta", replace
