

* COVID cases and deaths
import delimited "build/input/covid_counties.csv", clear varnames(1)

rename date tmp_date
gen date = date(tmp_date, "YMD")
format date %td

* Merge with NPIS data
merge m:1 state using "build/temp/cleaned_npis.dta", nogen keep(1 3)
drop shelter_in_place

* Merge with my dataset
merge m:1 state using "build/temp/stay_at_home.dta", nogen keep (1 3)
rename stay_at_home shelter_in_place

* Merge with dine-in-bans
merge m:1 state using "build/temp/dine_in_bans.dta", nogen

* Merge with mobilities
merge m:1 state county date using "build/temp/mobility_counties.dta"
