/*
Computes the Tornquist index for each sector, C and S.
*/

clear

use "build/temp/value_added_long.dta"

local priceind "build/temp/price_indexes_long.dta"
merge 1:1 industry sector year using "`priceind'", nogen

keep if year >= 1963
rename industry indtitle
encode indtitle, gen(industry)

* Total value added by sector
rename value_added industry_value_added
bysort sector year: egen sector_value_added = total(industry_value_added)

* Compute Tornquist log(P_{j,t} / P_{j,t-1})
tsset industry year
gen ld_industry_price = log(price / l.price)

gen weight = industry_value_added / sector_value_added

gen sum_terms = (weight + l.weight) * ld_industry_price / 2
bysort sector year: egen ld_sector_price = total(sum_terms)
drop weight price sum_terms ld_industry_price industry_value_added

duplicates drop sector year, force
drop indtitle industry

* Compute P_{j,t}
tsset sector year

gen sector_price = 1 if year == 1963
forvalues yr = 1964/2019 {
	replace sector_price = l.sector_price * exp(ld_sector_price) if (year == `yr')
}
drop ld_sector_price

* Quantities
gen quantity = sector_value_added / sector_price

* Renaming
decode sector, gen(seclab)
drop sector
rename sector_price P
rename sector_value_added Y
rename quantity Q

* Reshape wide
reshape wide Y P Q, i(year) j(seclab) string
label variable YC "Nominal value added in billions, sector C"
label variable YS "Nominal value added in billions, sector S"
label variable PC "Tornquist index, sector C"
label variable PS "Tornquist index, sector S"
label variable QC "Quantity, sector C"
label variable QS "Quantity, sector S"

save "build/output/tornquist_series.dta", replace
