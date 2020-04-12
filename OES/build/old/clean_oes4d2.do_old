clear

`#PREREQ' local essential "../industries/build/input/essential_industries.csv"
import delimited "`essential'", varnames(1)
gen essential = 1
save "build/temp/essential.dta", replace

// GET 4-DIGIT OCC VARIABLE
use "build/temp/oes4d_temp.dta", clear

gen soc3d2010 = substr(OCC_CODE, 1, 4)
replace soc3d2010 = subinstr(soc3d2010, "-", "", .)
destring soc3d2010, replace

do "../occupations/build/output/occ3labels2010.do"
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

* Save
save "build/output/oes4d_cleaned.dta", replace


* Stats
use "build/output/oes4d_cleaned.dta", clear
keep if OCC_GROUP == "minor"

#delimit ;
keep NAICS NAICS_TITLE soc3d2010 employment;
#delimit cr

rename NAICS naics

replace naics = subinstr(naics, "A", "0", .)
destring naics, replace

merge m:1 naics using "build/temp/essential.dta", keep(1 3) nogen keepusing(essential)
replace essential = 0 if missing(essential)
keep employment soc3d2010 essential

// gen marker = 1
collapse (mean) essential [iw=employment], by(soc3d2010)
