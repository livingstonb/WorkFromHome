/*
Cleans and merges country-level data.
*/

clear
import delimited using "build/input/OxCGRT_latest.csv", varnames(1)

rename date datenum
tostring datenum, replace
gen date = date(datenum, "YMD")
format %td date
drop datenum

rename countrycode cntrycode
rename countryname country

* Merge with population
preserve

import delimited "build/input/global_populations.csv", clear varnames(1)
tempfile populations
save `populations'

restore
merge m:1 cntrycode using `populations', nogen keep(1 3)

* Merge with mobility data
merge 1:1 country date using "build/temp/mobility_country.dta", nogen keep(1 3)

* Merge with cases
merge 1:1 country date using "build/temp/global_cases.dta", nogen keep(1 3)

* Merge with recoveries
merge 1:1 country date using "build/temp/global_recoveries.dta", nogen keep(1 3)

* Merge with deaths
merge 1:1 country date using "build/temp/global_deaths.dta", nogen keep(1 3)

* Drop early/late entries
quietly sum date if !missing(mobility_work)
drop if date < r(min)
drop if date > r(max)

* Tag countries
gen tag = (date == date("2020-03-19", "YMD"))

* Country identifier
encode country, gen(cntryid)

* No mobility data
bysort country: egen mob_present = count(mobility_work)
drop if (mob_present == 0)
drop mob_present

* Save
save "build/temp/merged_global.dta", replace
