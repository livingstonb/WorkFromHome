/* --- HEADER ---
Reproduces the essential industries classifications from Brookings and
appends all non-essential industries as well.
*/

// PREPARE ESSENTIAL INDUSTRIES DATA
clear
`#PREREQ' local essential "build/input/essential_industries.csv"
import delimited "`essential'", varnames(1)
gen essential = 1

tempfile essential_tmp
save `essential_tmp', replace

// MERGE WITH OES
`#PREREQ' use "../OES/build/output/oes4d2017.dta", clear
keep if OCC_GROUP == "total"
keep NAICS NAICS_TITLE TOT_EMP A_MEAN OCC_CODE

rename A_MEAN meanwage
rename NAICS naicscode
rename TOT_EMP emp_oes

merge 1:1 naicscode using `essential_tmp', nogen
replace essential = 0 if missing(essential)

destring emp_oes, replace
destring meanwage, replace

drop dhscategory
rename NAICS_TITLE title_naics
rename naicscode naics
sort naics

`#TARGET' save "build/output/essential_industries_cleaned.dta", replace
