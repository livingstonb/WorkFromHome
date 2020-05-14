
clear
import delimited using "build/input/Global_Mobility_Report.csv", varnames(1)
keep if country_region_code == "US"
keep if sub_region_1 != ""
keep if sub_region_2 == ""
drop country_region* sub_region_2
rename sub_region_1 state

capture mkdir "build/temp"
export delimited "build/temp/cleaned_mobility_report.csv", replace

rename date tmp_date
gen date = date(tmp_date, "YMD")
format date %td
drop tmp_date

rename retail_and_recreation_percent_ch mobility_rr
rename workplaces_percent_change_from_b mobility_work

keep state mobility* date
save "build/temp/cleaned_mobility.dta", replace
