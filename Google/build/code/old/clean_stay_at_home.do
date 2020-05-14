

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
