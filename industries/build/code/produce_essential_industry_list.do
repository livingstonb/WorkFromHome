/*
Reproduces the essential industries classifications from Brookings and
appends all non-essential industries as well.
*/

// PREPARE ESSENTIAL INDUSTRIES DATA
clear
import delimited "build/input/essential_industries.csv", varnames(1)
gen essential = 1

tempfile essential_tmp
save `essential_tmp', replace

// MERGE WITH OES
import excel "../OES/build/input/nat4d2017", clear firstrow
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

drop industry

save "build/output/essential_industries_table.dta", replace
