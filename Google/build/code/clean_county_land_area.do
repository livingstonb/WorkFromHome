/*
Cleans Census data on county land area and pct rural vs. urban.
*/

clear
import excel using "build/input/PctUrbanRural_County.xls", firstrow

rename STATENAME statename
rename COUNTYNAME county
rename AREA_COU land
rename POPPCT_RURAL rural
rename POP_COU pop2010

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

quietly sum land
replace land = r(sum)

quietly sum rural [iw=pop2010]
replace rural = r(mean)

keep if _n == 1
replace county = "New York City"
keep statename county land rural

tempfile nyctemp
save `nyctemp'

restore

drop if (statename == "New York") & inlist(county, "New York", "Kings", "Queens", "Bronx", "Richmond")
append using `nyctemp'

keep statename county land rural
replace rural = rural / 100

label variable land "Land area in sq meters"
label variabl rural "Share of population in rural areas"

drop if statename == "Puerto Rico"

save "build/temp/county_land_areas.dta", replace
