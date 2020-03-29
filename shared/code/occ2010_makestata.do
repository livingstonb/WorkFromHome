clear

local occ2010dir "$WFHshared/occ2010"
cd "`occ2010dir'"

// GET LABELS FROM SOC
import delimited "temp/soc2010.csv", bindquote(strict)
drop v1

labmask occ3id, values(occ3labels) lblname(occ3d2010lbl)
keep soc occ3id
rename soc soc2010
rename occ3id occ3d2010

label variable soc2010 "SOC 2010 code"
label variable occ3d2010 "Occupation, 3-digit based on SOC 2010"

compress
capture mkdir "`occ2010dir'/output"
save "`occ2010dir'/temp/soc2010.dta", replace

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

rename soccode soc2010

compress
save "`occ2010dir'/temp/soc_3digit_map.dta", replace

// CREATE CORRESPONDENCE
use "`occ2010dir'/temp/soc_3digit_map.dta", clear

#delimit ;
merge 1:1 soc2010 using "`occ2010dir'/temp/soc2010.dta",
	keep(match) keepusing(occ3d2010) nogen;
#delimit cr

label variable soc2010 "SOC 2010 code"
label variable occcensus "Census occupation variable, occ"
gen occyear = 2010

compress
capture mkdir "`occ2010dir'/output"
save "`occ2010dir'/output/occindex2010.dta", replace
