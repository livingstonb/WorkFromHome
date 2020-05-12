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

* Identify weekends
gen day_of_week = dow(date)
gen weekend = inlist(day_of_week, 0, 6)

save "build/output/mobility_cleaned.dta", replace