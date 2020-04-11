/* --- HEADER ---
This do-file computes the share of each 3-digit occupation working in
essential industries according to OES data.
*/

// PREPARE ESSENTIAL INDUSTRIES DATA
clear
`#PREREQ' local essential "build/input/essential_industries.csv"
import delimited "`essential'", varnames(1)
gen essential = 1

tempfile essential_tmp
save `essential_tmp', replace

// GET 4-DIGIT INDUSTRY VARIABLE
`#PREREQ' use "../OES/build/output/oes4d.dta", clear

gen soc3d2010 = substr(OCC_CODE, 1, 4)
replace soc3d2010 = subinstr(soc3d2010, "-", "", .)
destring soc3d2010, replace

`#PREREQ' do "../occupations/build/output/occ3labels2010.do"
label values soc3d2010 soc3d2010_lbl
drop if missing(soc3d2010)

* Replace ** with missing
#delimit ;
local stringvars
	TOT_EMP PCT_TOTAL H_MEAN H_MEDIAN
	A_MEAN A_MEDIAN OCC_GROUP;
#delimit cr
foreach var of local stringvars  {
	replace `var' = "" if inlist(`var', "*", "**", "#")
	destring `var', replace
}

rename A_MEAN meanwage
label variable meanwage "Mean annual wage"

rename A_MEDIAN medianwage
label variable medianwage "Median annual wage"

rename TOT_EMP employment
label variable employment "Total employment rounded to nearest 10 (excl self-employed)"

rename PCT_TOTAL occshare_industry
label variable occshare_industry "% of industry employment in given occ, provided"

* Statistics
keep if OCC_GROUP == "minor"

#delimit ;
keep NAICS NAICS_TITLE soc3d2010 employment;
#delimit cr

rename NAICS naics
replace naics = subinstr(naics, "A", "0", .)
destring naics, replace

merge m:1 naics using `essential_tmp', keep(1 3) nogen keepusing(essential)
replace essential = 0 if missing(essential)
keep employment soc3d2010 essential

gen ones = 1
collapse (mean) essential (sum) employment=ones [iw=employment], by(soc3d2010)

`#TARGET' save "build/output/essential_workers.dta", replace
