
// * State-level
// clear
// import delimited using "build/input/Global_Mobility_Report.csv", varnames(1)
// keep if country_region_code == "US"
// keep if sub_region_1 != ""
// keep if sub_region_2 == ""
// drop country_region* sub_region_2
// rename sub_region_1 state
//
// capture mkdir "build/temp"
// export delimited "build/temp/cleaned_mobility_report.csv", replace
//
// rename date tmp_date
// gen date = date(tmp_date, "YMD")
// format date %td
// drop tmp_date
//
// rename retail_and_recreation_percent_ch mobility_rr
// rename workplaces_percent_change_from_b mobility_work
//
// keep state mobility* date
// save "build/temp/cleaned_mobility.dta", replace

* County level
clear
import delimited using "build/input/Global_Mobility_Report.csv", varnames(1)
keep if country_region_code == "US"
keep if sub_region_1 != ""
keep if sub_region_2 != ""
drop country_region*
rename sub_region_1 state
rename sub_region_2 county

rename date tmp_date
gen date = date(tmp_date, "YMD")
format date %td
drop tmp_date

rename retail_and_recreation_percent_ch mobility_rr
rename workplaces_percent_change_from_b mobility_work

replace county = "Baltimore city" if county == "Baltimore" & state == "Maryland"
replace county = "St. Louis city" if county == "St. Louis" & state == "Missouri"
replace county = "Fairfax city" if county == "Fairfax" & state == "Virginia"
replace county = "Franklin city" if county == "Franklin" & state == "Virginia"
replace county = "Richmond city" if county == "Richmond" & state == "Virginia"
replace county = "Roanoke city" if county == "Roanoke" & state == "Virginia"

replace county = subinstr(county, " County", "", .)
replace county = subinstr(county, " Parish", "", .)

keep state county mobility* date
sort state county date
order state county date
save "build/temp/mobility_counties.dta", replace

* Countries
clear
import delimited using "build/input/Global_Mobility_Report.csv", varnames(1)
keep if (sub_region_1 == "") & (sub_region_2 == "")

rename date datestr
gen date = date(datestr, "YMD")
format %td date

rename country_region_code ctrycode
rename country_region country
keep country ctrycode date retail* workplaces

rename retail_and_recreation_percent_ch mobility_rr
rename workplaces_percent_change_from_b mobility_work

* Recode some country names to match Google mobility data
replace country = "Czech Republic" if country == "Czechia"
replace country = "Cote d'Ivoire" if country == "CÃ´te d'Ivoire"
replace country = "Kyrgyz Republic" if country == "Kyrgyzstan"
replace country = "Myanmar" if country == "Myanmar (Burma)"
replace country = "Slovak Republic" if country == "Slovakia"

save "build/temp/mobility_country.dta", replace
