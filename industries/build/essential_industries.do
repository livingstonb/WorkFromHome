clear
capture mkdir "build/temp"
capture mkdir "build/output"

// PREPARE ESSENTIAL INDUSTRIES DATA
clear
import delimited "build/input/essential_industries.csv", varnames(1)
replace naics = naics / 100

replace naics = naics / 10 if inlist(naics, 4840, 3270, 5170, 5230)

drop description_naics
gen essential = 1
compress
save "build/temp/essential_industries.dta", replace

// Merge All 4-digit NAICS codes with essential industries data
clear
import delimited "build/input/naics_codes.csv", varnames(1)
replace naics = strtrim(naics)
replace description = strtrim(description)
rename description description_naics

* Extract 4-digit codes
keep if strlen(naics) == 4 | inlist(naics, "484", "327", "517", "523")
destring naics, replace

* Generate lower-digit categories
gen naics3d = floor(naics / 10) if naics >= 1000
gen naics2d = floor(naics / 100) if naics >= 1000
gen naics1d = floor(naics / 1000) if naics >= 1000

replace naics3d = naics if naics < 1000
replace naics2d = floor(naics / 10) if naics < 1000
replace naics1d = floor(naics / 100) if naics < 1000

* Perform merge
merge 1:1 naics using "build/temp/essential_industries.dta", nogen keep(1 3)

rename naics naics4d
replace naics4d = . if naics4d < 1000
replace essential = 0 if missing(essential)
order naics1d naics2d naics3d naics4d
egen naics = rowlast(naics*d)

save "build/temp/essential_industries_merged.dta", replace

// PREPARE CENSUS-INDUSTRY CROSSWALK
clear
use "build/output/industry2017crosswalk.dta"

* NAICS codes that include "Part of"
gen partial = strpos(naics, "Part of") > 0
replace partial = 1 if strpos(naics, "Pts.") > 0
label define partial_lbl 0 "Census code maps to naics directly"
label define partial_lbl 1 "Census code maps to part of naics code", add
label values partial partial_lbl
replace naics = subinstr(naics, "Part of ", "", .)
replace naics = subinstr(naics, "Pts. ", "", .)

* Replace "and" with comma
replace naics = subinstr(naics, " and ", ", ", .)

* Deal with exclusions
split naics, gen(exclusions) parse(" exc. ")
rename exclusions1 indtmp
rename exclusions2 excludedtmp

* Separate multiple industries per category
split indtmp, gen(industry) parse(", " ",") destring
split excludedtmp, gen(excluding) parse(", " ",") destring

egen nexcl = rownonmiss(excluding*)
gen noexclusions = (nexcl == 0)

drop indtmp excludedtmp nexcl
save "build/temp/census_industry_cwalk_for_essential.dta", replace

* Loop through industries and merge
foreach var of varlist industry* {
foreach digit of numlist 4 3 2 1 {
	rename `var' naics`digit'd
	
	#delimit ;
	merge m:m naics`digit'd using "build/temp/essential_industries_merged.dta",
		nogen keep(1 3 4) keepusing(essential);
	#delimit cr
	
	rename naics`digit'd `var'
}
}
