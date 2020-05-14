/*
Cleans the MATLAB time series of state-level Google mobility data and resaves
in Stata format.
*/

clear
local csvpath "build/output/state_time_series.csv"
import delimited "`csvpath'"
drop grocery* parks transit* residential

local cst_vars stay_at_home state_of_emergency
foreach name of local cst_vars  {
	rename `name'_cst cst_`name'
}
rename business_closure_cst business_closure

#delimit ;
foreach var of varlist
	date school_closure business_closure
	stay_at_home dine_in_ban cst*  {;

	replace `var' = strtrim(`var');
	replace `var' = "" if (`var' == "NaT");
	rename `var' temp_var;
	gen `var' = date(temp_var, "MDY");
	format %td `var';
	drop temp_var;
};
#delimit cr

rename retail_and_recreation_percent_ch mobility_rr
rename workplaces_percent_change_from_b mobility_work

label variable date "Date"

* Identify weekends
gen day_of_week = dow(date)

label define day_of_week_lbl 0 "Sunday"
label define day_of_week_lbl 1 "Monday", add
label define day_of_week_lbl 2 "Tuesday", add
label define day_of_week_lbl 3 "Wednesday", add
label define day_of_week_lbl 4 "Thursday", add
label define day_of_week_lbl 5 "Friday", add
label define day_of_week_lbl 6 "Saturday", add
label values day_of_week day_of_week_lbl
label variable day_of_week "Day of week"

gen weekend = inlist(day_of_week, 0, 6)
label variable weekend "Dummy variable for weekend"

* State id
rename state statename
encode statename, gen(stateid)

order stateid date


* Declare panel
tsset stateid date

* Flows: cases and deaths per 10,000 people
gen cases = 10000 * d.cum_cases / population
gen deaths = 10000 * d.cum_deaths / population

save "build/output/mobility_cleaned.dta", replace
