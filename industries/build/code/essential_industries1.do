/* --- HEADER ---
Computes the share of each 3-digit occupation working in
essential industries according to OES data.
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
keep if OCC_GROUP == "minor"
keep NAICS NAICS_TITLE TOT_EMP A_MEAN OCC_CODE

rename A_MEAN meanwage
rename NAICS naicscode
rename TOT_EMP emp_oes

replace emp_oes = "" if inlist(emp_oes, "*", "**", "#")
destring emp_oes, replace

merge m:1 naicscode using `essential_tmp', nogen
replace essential = 0 if missing(essential)

destring emp_oes, replace
destring meanwage, replace

drop dhscategory
rename NAICS_TITLE title_naics
rename naicscode naics
sort naics

// GENERATE OCCUPATION CODES
gen soc3d2010 = substr(OCC_CODE, 1, 4)
replace soc3d2010 = subinstr(soc3d2010, "-", "", .)
destring soc3d2010, replace

`#PREREQ' do "../occupations/build/output/occ3labels2010.do"
label values soc3d2010 soc3d2010_lbl
drop if missing(soc3d2010)

// COLLAPSE
gen ones = 1
drop employment
rename emp_oes employment
collapse (mean) essential (sum) employment=ones [iw=employment], by(soc3d2010)

`#TARGET' save "build/output/essential_workers.dta", replace
