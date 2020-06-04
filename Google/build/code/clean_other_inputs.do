

* COVID cases and deaths
import delimited "build/input/covid_counties.csv", clear varnames(1)

rename date tmp_date
gen date = date(tmp_date, "YMD")
format date %td

drop tmp_date fips

save "build/temp/covid_deaths.dta", replace

* IHME data
clear
import delimited "build/input/ihme_summary_stats.csv", varnames(1)

* Add missing stay-at-home dates
replace stay_home_end_date = "2020-05-20" if location_name == "Connecticut"
replace stay_home_end_date = "2020-06-01" if location_name == "Delaware"
replace stay_home_end_date = "2020-04-31" if location_name == "Georgia"
replace stay_home_end_date = "2020-06-01" if location_name == "Hawaii"
replace stay_home_end_date = "2020-05-29" if location_name == "Illinois"
replace stay_home_end_date = "2020-06-01" if location_name == "Maine"
replace stay_home_end_date = "2020-05-15" if location_name == "Maryland"
replace stay_home_end_date = "2020-05-18" if location_name == "Massachusetts"
replace stay_home_end_date = "2020-06-12" if location_name == "Michigan"
replace stay_home_end_date = "2020-06-01" if location_name == "New Hampshire"
replace stay_home_end_date = "2020-06-05" if location_name == "New Jersey"
replace stay_home_end_date = "2020-05-31" if location_name == "New Mexico"
replace stay_home_end_date = "2020-05-28" if location_name == "New York"
replace stay_home_end_date = "2020-05-29" if location_name == "Ohio"
replace stay_home_end_date = "2020-06-04" if location_name == "Pennsylvania"
replace stay_home_end_date = "2020-04-30" if location_name == "Tennessee"
replace stay_home_end_date = "2020-06-10" if location_name == "Virginia"

gen gathering_restriction = date(any_gathering_restrict_start_dat, "YMD")
gen non_essential_closure = date(all_noness_business_start_date, "YMD")
gen lifted_shelter_in_place = date(stay_home_end_date, "YMD")

format %td gathering_restriction
format %td non_essential_closure
format %td lifted_shelter_in_place

rename location_name statename
keep statename gathering_restriction non_essential_closure lifted_shelter_in_place

save "build/output/ihme_summary_stats.dta", replace

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

replace date = . if inlist(state, "Oklahoma", "Utah", "Wyoming")

rename date stay_at_home
keep state stay_at_home
save "build/temp/stay_at_home.dta", replace
