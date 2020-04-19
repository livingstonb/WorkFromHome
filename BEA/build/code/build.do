clear

`#PREREQ 'import excel "build/input/value_added_1947_1997.xls", firstrow

drop line
foreach var of varlist * {
	if !inlist("`var'", "title", "sector") {
		local lab: variable label `var'
		rename `var' value_added`lab'
	}
}
drop if missing(sector)

* Reshape
reshape long value_added, i(title) j(year)
destring value_added, force replace

* Split "Other transportation and support activities"
expand 2 if (sector == 2), gen(iexpand)
replace value_added = value_added / 2 if (sector == 2)
replace sector = 0 if (sector == 2) & !iexpand
replace sector = 1 if iexpand
drop iexpand
