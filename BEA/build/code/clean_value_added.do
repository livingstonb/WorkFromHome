/*
Cleans industry-level value-added from BEA.
*/

clear

* 1947 - 1997
tempfile value_added1947
import excel "build/input/value_added_1947_1997.xls", firstrow
drop if missing(sector)

drop line
foreach var of varlist * {
	if !inlist("`var'", "title", "sector") {
		local lab: variable label `var'
		destring `var', force replace
		rename `var' value_added`lab'
	}
}
save `value_added1947', replace

* 1998 - 2019
clear
import excel "build/input/value_added_1998_2019.xls", firstrow
drop if missing(sector)

drop line
foreach var of varlist * {
	if !inlist("`var'", "title", "sector") {
		local lab: variable label `var'
		rename `var' value_added`lab'
	}
}
destring value_added2019, force replace

* Merge years
merge 1:1 title using `value_added1947', nogen

label define sector_lbl 0 "C" 1 "S"
label values sector sector_lbl

reshape long value_added, i(title) j(year)

* Split "Other transportation and support activities"
expand 2 if (sector == 2), gen(iexpand)
replace value_added = value_added / 2 if (sector == 2)

replace title = title + " (1)" if (sector == 2) & !iexpand
replace sector = 0 if (sector == 2) & !iexpand

replace sector = 1 if iexpand
replace title = title + " (2)" if iexpand
drop iexpand

* Save
rename title industry
save "build/temp/value_added_long.dta", replace
