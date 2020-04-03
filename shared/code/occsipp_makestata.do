clear

// GET LABELS FROM SOC
// import delimited "$WFHshared/occ2010/temp/soc2010.csv", bindquote(strict)
// drop v1
//
// labmask occ3id, values(occ3labels) lblname(occ3d2010lbl)
// keep soc* occ3id
// rename soc3d soc3d2010
// rename socfull soc2010
// rename occ3id occ3d2010
//
// label variable soc3d2010 "SOC 2010, 3-digit level"
// label variable soc2010 "SOC 2010 code"
// label variable occ3d2010 "Occupation, 3-digit based on SOC 2010"
//
// replace soc3d2010 = "51-5100" if (soc3d2010 == "51-5000")
// replace soc3d2010 = "15-1100" if (soc3d2010 == "15-1000")
//
// compress
// capture mkdir "$WFHshared/occsipp/temp"
// save "$WFHshared/occsipp/temp/occsipp.dta", replace

// USE 2013 ACS/2014 SIPP codes
clear
import delimited "$WFHshared/occsipp/input/acs2013sipp2014.csv", bindquotes(strict)

rename v1 occcensus
rename v2 soc2010
drop if _n == 1

drop if soc2010 == ""
replace soc2010 = strtrim(soc2010)
replace soc2010 = subinstr(soc2010, "X", "0", .)
replace soc2010 = subinstr(soc2010, "Y", "0", .)
drop if strlen(soc2010) > 7

replace occcensus = strtrim(occcensus)
drop if occcensus == ""
drop if strlen(occcensus) > 4

destring occcensus, replace

replace soc2010 = "17-2000" if inlist(occcensus, 1520, 1530)
replace soc2010 = "29-1000" if (occcensus == 3258)
replace soc2010 = "47-2000" if (occcensus == 6765)
replace soc2010 = "51-9000" if (occcensus == 8965)
replace soc2010 = "53-7000" if (occcensus == 9750)

compress
save "$WFHshared/occsipp/temp/soc_3digit_map.dta", replace

// MERGE
use "$WFHshared/occsipp/temp/soc_3digit_map.dta", clear

#delimit ;
merge m:1 soc2010 using "$WFHshared/occ2010/occ/temp/occ2010new.dta",
	keepusing(minor2010 soc3d2010) keep(match master) nogen;
#delimit cr
rename minor2010 occ3d2010

label variable soc2010 "SOC 2010 code"
label variable occcensus "Census occupation variable, occ"
gen occyear = 2010

compress
capture mkdir "$WFHshared/occsipp/output"
save "$WFHshared/occsipp/output/occindexsipp.dta", replace
