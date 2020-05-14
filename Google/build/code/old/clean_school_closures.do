

clear
import delimited "build/input/school_closures.csv"

drop if _n == 1

rename v1 state
rename v5 date
drop v*

foreach var of varlist _all {
	replace `var' = strtrim(`var')
}

drop if date == "n/a"

gen school_closure = date(date, "MDY")
format school_closure %td
drop date

save "build/temp/school_closures.dta", replace
