clear

local occ2018dir "$WFHshared/occ2018"
cd "`occ2018dir'"

// GET LABELS FROM SOC
import delimited "temp/soc2018.csv", bindquote(strict)
drop v1

labmask occ3id, values(occ3labels) lblname(occ3d2018lbl)
keep soc* occ3id
rename soc3d soc3d2018
rename socfull soc2018
rename occ3id occ3d2018

label variable soc2018 "SOC 2018 code"
label variable occ3d2018 "Occupation, 3-digit based on SOC 2018"
replace soc3d2018 = "51-5100" if (soc3d2018 == "51-5000")
replace soc3d2018 = "15-1200" if (soc3d2018 == "15-1000")
replace soc3d2018 = "31-1100" if (soc3d2018 == "31-1000")

compress
capture mkdir "`occ2018dir'/output"
save "`occ2018dir'/temp/soc2018.dta", replace

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

rename soccode soc2018

compress
save "`occ2018dir'/temp/soc_3digit_map.dta", replace

// CREATE CORRESPONDENCE
use "`occ2018dir'/temp/soc_3digit_map.dta", clear

#delimit ;
merge 1:1 soc2018 using "`occ2018dir'/temp/soc2018.dta",
	keep(match master) keepusing(occ3d2018) nogen;
#delimit cr

label variable soc2018 "SOC 2018 code"
label variable occcensus "Census occupation variable, occ"

drop if occ3d2018 == .
gen occyear = 2018

compress
capture mkdir "`occ2018dir'/output"
save "`occ2018dir'/output/occindex2018.dta", replace
