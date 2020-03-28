clear

local occ2010dir "$WFHshared/occ2010"
cd "`occ2010dir'"

// GET LABELS FROM SOC
import delimited "temp/soc_labels.csv", bindquote(strict)

labmask catid, values(category) lblname(category_lbl)
rename fcode soccode
rename catid occ3digit

replace soccode = strtrim(soccode)
order soccode occ3digit
keep soccode occ3digit

compress
capture mkdir "`occ2010dir'/output"
save "`occ2010dir'/temp/soc_labels.dta", replace

// GET CENSUS-SOC MAP
clear
import delimited "input/soc_3digit_map.csv", bindquote(strict)
rename v1 occcensus
rename v2 soccode
drop if _n == 1

drop if soccode == ""
replace soccode = strtrim(soccode)
replace soccode = subinstr(soccode, "X", "0", .)

replace occcensus = strtrim(occcensus)
drop if strlen(occcensus) > 4
destring occcensus, replace

compress
save "`occ2010dir'/temp/soc_3digit_map.dta", replace

// CREATE CORRESPONDENCE
use "`occ2010dir'/temp/soc_3digit_map.dta", clear

#delimit ;
merge 1:1 soccode using "`occ2010dir'/temp/soc_labels.dta",
	keep(match master) keepusing(occ3digit) nogen;
#delimit cr

compress
capture mkdir "`occ2010dir'/output"
save "`occ2010dir'/output/occindex2010.dta", replace
