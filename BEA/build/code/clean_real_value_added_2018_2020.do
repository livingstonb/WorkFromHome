/*
Cleans industry-level value-added from BEA.
*/

* Read
clear
import excel "build/input/real_value_added_2018_2020.xls", firstrow
drop if missing(sector)

drop line
foreach var of varlist * {
	if !inlist("`var'", "title", "sector") {
		local lab: variable label `var'
		rename `var' va_`lab'
		destring va_`lab', force replace
	}
}

* Split "Other transportation and support activities"
expand 2 if (sector == 2), gen(iexpand)

foreach var of varlist va_* {
	replace `var' = `var' / 2 if (sector == 2)
}

replace title = title + " (1)" if (sector == 2) & !iexpand
replace sector = 0 if (sector == 2) & !iexpand

replace sector = 1 if iexpand
replace title = title + " (2)" if iexpand
drop iexpand

label define sector_lbl 0 "C" 1 "S"
label values sector sector_lbl

drop va_2018q1-va_2019q3

collapse (sum) va_2019q4 (sum) va_2020q1 (sum) va_2020q2, by(sector)
label variable va_2019q4 "Real value added in 2019Q4"
label variable va_2020q1 "Real value added in 2020Q1"
label variable va_2020q2 "Real value added in 2020Q2"

* Save
export excel using "build/output/value_added_2019q4_2020q2.xlsx", replace firstrow(varlabels)
