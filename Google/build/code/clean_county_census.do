
clear
import excel using "build/input/PctUrbanRural_County.xls", firstrow

rename STATENAME statename
rename COUNTYNAME county
rename AREA_COU land

destring STATE, force replace
destring COUNTY, force replace

replace county = "St. Louis city" if (STATE == 29) & (COUNTY == 510)
replace county = "Baltimore city" if (STATE == 24) & (COUNTY == 510)
replace county = "Bedford city" if (STATE == 51) & (COUNTY == 515)
replace county = "Fairfax city" if (STATE == 51) & (COUNTY == 600)
replace county = "Franklin city" if (STATE == 51) & (COUNTY == 620)
replace county = "Richmond city" if (STATE == 51) & (COUNTY == 760)
replace county = "Roanoke city" if (STATE == 51) & (COUNTY == 770)

preserve

keep if statename == "New York"
keep if inlist(county, "New York", "Kings", "Queens", "Bronx", "Richmond")
collapse (firstnm) statename (sum) land
gen county = "New York City"

tempfile nyctemp
save `nyctemp'

restore

drop if (statename == "New York") & inlist(county, "New York", "Kings", "Queens", "Bronx", "Richmond")
append using `nyctemp'

keep statename county land

save "build/temp/county_land_areas.dta", replace
