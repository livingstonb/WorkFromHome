
clear
import excel "build/input/census_populations.xlsx", firstrow

keep state land pop2019

replace state = subinstr(state, ".", "", .)
gen persons_per_sqmi = pop2019 / land
rename pop2019 population

drop if missing(state)

save "build/temp/populations.dta", replace
