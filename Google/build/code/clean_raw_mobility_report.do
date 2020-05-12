
clear
import delimited using "build/input/Global_Mobility_Report.csv", varnames(1)
keep if country_region_code == "US"
keep if sub_region_1 != ""
keep if sub_region_2 == ""
drop country_region* sub_region_2
rename sub_region_1 state

export delimited "build/temp/cleaned_mobility_report.csv", replace
