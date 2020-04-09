clear
capture mkdir "build/temp"
capture mkdir "build/output"

// PREPARE ESSENTIAL INDUSTRIES DATA
clear
import delimited "build/input/essential_industries.csv", varnames(1)
gen code4d = naics / 100
gen code3d = floor(naics / 1000)

gen is3digit = (naics / 1000 == code3d)
replace code4d = . if is3digit
replace code3d = . if !is3digit

drop description_naics is3digit
gen essential = 1
compress
save "build/temp/essential_industries.dta", replace

// Merge All 4-digit NAICS codes with essential industries data
clear
import delimited "build/input/naics_codes.csv", varnames(1)
replace naics = strtrim(naics)
replace description = strtrim(description)
rename description description_naics

* Extract different classifications
keep if strlen(naics) == 6

gen code2d = substr(naics, 1, 2)
destring code2d, replace

gen code3d = substr(naics, 1, 3)
destring code3d, replace

gen code4d = substr(naics, 1, 4)
destring code4d, replace

destring naics, replace

* Perform merge
forvalues d = 3/4 {
	#delimit ;
	merge m:m code`d'd using "build/temp/essential_industries.dta",
		nogen keep(1 3 4) update keepusing(essential);
	#delimit cr
}
replace essential = 0 if missing(essential)

save "build/temp/essential_industries_merged.dta", replace

// PREPARE CENSUS-INDUSTRY CROSSWALK
clear
use "build/output/industry2017crosswalk.dta"

* NAICS codes that include "Part of"
gen partial = strpos(naics, "Part of") > 0
replace partial = 1 if strpos(naics, "Pts.") > 0
label define partial_lbl 0 ""
label define partial_lbl 1 "Listed as 'Part of' industries", add
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
label define nexc_lbl 0 "Some sub-industries excluded" 1 ""
label values noexclusions nexc_lbl

drop indtmp excludedtmp nexcl
save "build/temp/census_industry_cwalk_for_essential.dta", replace
//
// * Loop through industries and merge
// foreach var of varlist industry* {
// foreach digit of numlist 4 3 2 1 {
// 	rename `var' naics`digit'd
//	
// 	#delimit ;
// 	merge m:m naics`digit'd using "build/temp/essential_industries_merged.dta",
// 		nogen keep(1 3 4) keepusing(essential);
// 	#delimit cr
//	
// 	rename naics`digit'd `var'
// }
// }

// NOW MERGE BOTH
use "build/temp/essential_industries_merged.dta", clear

