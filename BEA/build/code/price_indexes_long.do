/* --- HEADER ---
Cleans industry-level price indexes from BEA.
*/

clear

* 1947 - 1997
tempfile price1947
`#PREREQ 'import excel "build/input/price_indexes_1947_1997.xls", firstrow
drop if missing(sector)

drop line
foreach var of varlist * {
	if !inlist("`var'", "title", "sector") {
		local lab: variable label `var'
		destring `var', force replace
		rename `var' price_index`lab'
	}
}
save `price1947', replace

* 1998 - 2019
clear
`#PREREQ 'import excel "build/input/price_indexes_1998_2019.xls", firstrow
drop if missing(sector)

drop line
foreach var of varlist * {
	if !inlist("`var'", "title", "sector") {
		local lab: variable label `var'
		rename `var' price_index`lab'
	}
}
destring price_index2019, force replace

* Merge years
merge 1:1 title using `price1947', nogen

label define sector_lbl 0 "C" 1 "S"
label values sector sector_lbl

reshape long price_index, i(title) j(year)

* Split "Other transportation and support activities"
expand 2 if (sector == 2), gen(iexpand)
replace title = title + " (1)" if (sector == 2) & !iexpand
replace sector = 0 if (sector == 2) & !iexpand

replace sector = 1 if iexpand
replace title = title + " (2)" if iexpand
drop iexpand

* Save
rename title industry
rename price_index price
`#TARGET' save "build/temp/price_indexes_long.dta", replace
