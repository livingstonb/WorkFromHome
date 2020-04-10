/* --- MAKEFILE INSTRUCTIONS ---
`#PREREQ' "../ado/rowdistinct.ado"
*/

/* This do-file creates a crosswalk with industry descriptions, NAICS codes,
Census codes, and the C/S sector designation. */
clear
adopath + "../ado"

// PREPARE ESSENTIAL INDUSTRIES DATA
clear

`#PREREQ' local essential "build/input/essential_industries.csv"
import delimited "`essential'", varnames(1)
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

`#PREREQ' local naics "build/input/naics_codes.csv"
import delimited "`naics'", varnames(1)
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

gen code5d = substr(naics, 1, 5)
destring code5d, replace

destring naics, replace
gen code6d = naics

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
`#PREREQ' use "build/output/industry2017crosswalk.dta", clear

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

// NOW MERGE BOTH
use "build/temp/essential_industries_merged.dta", clear

local k = 1
tempfile mtmp1 mtmp2
forvalues i = 1/7 {
foreach d of numlist 2/6 {
	preserve
	use "build/temp/census_industry_cwalk_for_essential.dta", clear
	rename industry`i' code`d'd
	drop if partial == 1
	
	save `mtmp1', replace
	restore
	
	* Make copy of current dataset with unique ids, perform merge
	preserve
	duplicates drop code`d'd, force
	
	#delimit ;
	merge 1:m code`d'd using `mtmp1',
		keep(1 3 4) keepusing(census) nogen update;
	#delimit cr

	save `mtmp2', replace
	restore
	
	* Now merge back
	#delimit ;
	merge m:1 code`d'd using `mtmp2',
		keep(1 3) keepusing(census) nogen update;
	#delimit cr
	rename census indcensus`k'

	local ++k
}
}

gen nobs = _n
rowdistinct indcensus*, gen(cunique) id(nobs)
drop indcensus* nobs

* Drop exclusions
foreach var of varlist cunique* {
	rename `var' census
	#delimit ;
	merge m:1 census using "build/temp/census_industry_cwalk_for_essential.dta",
		keep(1 3) keepusing(excluding*) nogen;
	#delimit cr
	rename census `var'

	forvalues d = 2/6 {
		forvalues i = 1/4 {
			replace `var' = . if code`d'd == excluding`i'
		}
	}
	drop excluding*
}
egen v1census = rowfirst(cunique*)
drop cunique*

* Merge in partial matches
local k = 1
tempfile ptmp1 ptmp2
forvalues i = 1/7 {
foreach d of numlist 2/6 {
	preserve
	use "build/temp/census_industry_cwalk_for_essential.dta", clear
	rename industry`i' code`d'd
	keep if partial == 1
	
	save `ptmp1', replace
	restore
	
	* Make copy of current dataset with unique ids, perform merge
	preserve
	duplicates drop code`d'd, force
	
	#delimit ;
	merge 1:m code`d'd using `ptmp1',
		keep(1 3 4) keepusing(census) nogen update;
	#delimit cr

	save `ptmp2', replace
	restore
	
	* Now merge back
	#delimit ;
	merge m:1 code`d'd using `ptmp2',
		keep(1 3) keepusing(census) nogen update;
	#delimit cr
	rename census indcensus`k'

	local ++k
}
}

gen nobs = _n
rowdistinct indcensus*, gen(v2census) id(nobs)
drop indcensus* nobs

// CLEAN
rename v1census census_matched

local i = 1
foreach var of varlist v2census* {
	rename `var' census_partial`i'
	local ++i
}

drop code6d
label variable naics "Full six-digit NAICS category"
label variable code2d "NAICS first two digits"
label variable code3d "NAICS first three digits"
label variable code4d "NAICS first four digits"
label variable code5d "NAICS first five digits"
label variable census_match "Census industry code"
label variable census_partial1 "Census industry code, if partial match only"
label variable census_partial2 "Census industry code, if partial match only"

* Indicator for if matched census code has a non-constant "essential" value
bysort census_match (essential): gen mixed = (essential[_N] != essential[1])
replace mixed = . if missing(census_match)
label define mixed_lbl 0 "Census code has homogenous essential/non-essential"
label define mixed_lbl 1 "Census code has mixed essential and non-essential", add
label values mixed mixed_lbl
label variable mixed "Census code-level indicator for presence of mixed essential/non-essential"

* Essential labels
label variable essential "Indicator for essential industry"
label define essential_lbl 0 "Not essential" 1 "Essential"
label values essential essential_lbl

* Save and clean up
sort census_match

`#TARGET' save "build/output/essential_industries.dta", replace

erase "build/temp/essential_industries.dta"
erase "build/temp/essential_industries_merged.dta"
erase "build/temp/census_industry_cwalk_for_essential.dta"
