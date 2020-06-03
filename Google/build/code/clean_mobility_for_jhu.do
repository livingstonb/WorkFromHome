
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

// replace county = "Baltimore city" if county == "Baltimore" & state == "Maryland"
// replace county = "St. Louis city" if county == "St. Louis" & state == "Missouri"
// replace county = "Fairfax city" if county == "Fairfax" & state == "Virginia"
// replace county = "Franklin city" if county == "Franklin" & state == "Virginia"
// replace county = "Richmond city" if county == "Richmond" & state == "Virginia"
// replace county = "Roanoke city" if county == "Roanoke" & state == "Virginia"

gen has_label = strpos(county, "County") + strpos(county, "Parish") + strpos(county, "Municipality") + strpos(county, "Borough") > 0
replace county = county + " city" if !has_label & (state != "Alaska")

* Rename some counties
replace county = "Kenai Peninsula" if county == "Kenai Peninsula Borough"

// replace county = subinstr(county, " County", "", .)
// replace county = subinstr(county, " Parish", "", .)

// * Combine 5 boroughs
// gen NY = inlist(fips, 36005, 36047, 36061, 36081, 36085)
// bysort date: egen ny_work = mean(mobility_work) if NY
// bysort date: egen ny_rr = mean(mobility_rr) if NY
// replace fips = 99991 if fips == 36061
// replace county = "New York City" if fips == 99991
// replace cases = ny_cases if fips == 99991
// replace deaths = ny_deaths if fips == 99991
// drop if NY & (fips != 99991)
//


keep state county mobility* date
sort state county date
order state county date

rename state statename
save "build/temp/mobility_for_jhu.dta", replace
