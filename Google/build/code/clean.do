

* COVID cases and deaths
import delimited "build/input/covid_deaths.csv", clear varnames(1)

rename date tmp_date
gen date = date(tmp_date, "YMD")
format date %td

drop tmp_date fips

save "build/temp/covid_deaths.dta", replace

* Dine-in bans
clear
import delimited "build/input/dine_in_bans.csv", varnames(1)

rename dine_in_ban tmp_dine_in_ban
gen dine_in_ban = date(tmp_dine_in_ban, "YMD")
format dine_in_ban %td

drop tmp_dine_in_ban

save "build/temp/dine_in_bans.dta", replace

* NPIS data
clear
import delimited "build/input/complete_npis_raw_policies.csv", varnames(1)

drop if strlen(county) > 0

gen date = date(start_date, "MDY")
format date %td
drop start_date end_date citation note county fip_code

#delimit ;
keep if inlist(npi,
	"shelter_in_place", "school_closure", "non-essential_services_closure");
#delimit cr

replace npi = "non_essential_closure" if npi == "non-essential_services_closure"

rename date date_
reshape wide date_, i(state) j(npi) string

rename date_non_essential_closure non_essential_closure
rename date_school_closure school_closure
rename date_shelter_in_place shelter_in_place

save "build/temp/cleaned_npis.dta", replace

* State population levels
clear
import excel "build/input/census_populations.xlsx", firstrow

keep state land pop2019

replace state = subinstr(state, ".", "", .)
gen persons_per_sqmi = pop2019 / land
rename pop2019 population

drop if missing(state)

save "build/temp/populations.dta", replace

* School closures data
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

* Stay-at-home orders
clear
import delimited "build/temp/stay_at_home.csv", varnames(1)

split date, gen(dcomp)
rename dcomp1 month
rename dcomp2 day_of_month
rename dcomp3 hour
rename dcomp4 tperiod

foreach var of varlist _all {
	replace `var' = strtrim(`var')
}

destring hour, force replace
replace hour = hour + 12 if tperiod == "PM"
drop tperiod

gen year = "2020"

rename date orig_date
gen tmp_date = day + " " + month + " " + year
gen date = date(tmp_date, "DMY")
format date %td
drop tmp_date

replace date = date + 1 if hour > 8

rename date stay_at_home
keep state stay_at_home
save "build/temp/stay_at_home.dta", replace