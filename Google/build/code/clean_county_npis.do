clear
import delimited "build/input/complete_npis_inherited_policies.csv", varnames(1)
drop if county == ""
drop citation note end_date

keep if npi == "shelter_in_place"
drop npi
rename fip_code fips

gen cty_shelter_in_place = date(start_date, "MDY")
format %td cty_shelter_in_place
drop start_date

rename state statename

save "build/temp/county_npis.dta", replace
