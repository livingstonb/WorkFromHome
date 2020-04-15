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
import excel "../OES/build/input/nat4d2017", clear firstrow

* Clean
`#PREREQ' do "../OES/build/code/clean_oes_generic.do" 2017 1

rename a_mean meanwage
rename tot_emp emp_oes

merge m:1 naicscode using `essential_tmp', nogen
replace essential = 0 if missing(essential)

destring emp_oes, replace
destring meanwage, replace

sort naicscode

// COLLAPSE
gen ones = 1
drop employment
rename emp_oes employment
collapse (mean) essential (sum) employment=ones [iw=employment], by(soc3d2010)

`#TARGET' save "build/output/essential_share_by_occ.dta", replace