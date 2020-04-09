
clear
discard
adopath + "../ado"

#delimit ;
import delimited "build/input/census_naics_2017.csv",
	bindquotes(strict) varnames(1);
#delimit cr

* Sector
replace sector = "-1" if sector == "NA"
destring sector, replace
filldown sector
drop if sector == -1

* Census codes
replace census = strtrim(census)
drop if strpos(census, "-") > 0
destring census, replace
drop if missing(census)

* Drop duplicates
replace description = strtrim(description)
duplicates tag census, gen(cdupe)
drop if (cdupe == 1) & (description == "")
drop cdupe

duplicates drop census description, force

* Save
