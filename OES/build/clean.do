
// GET 3-DIGIT OCC VARIABLE
use "$OESbuild/input/oes_raw.dta", clear

gen soc3d2010 = substr(OCC_CODE, 1, 4)
replace soc3d2010 = subinstr(soc3d2010, "-", "", .)
destring soc3d2010, replace

do "$WFHshared/occupations/output/occ3labels2010.do"
label values soc3d2010 soc3d2010_lbl

// MERGE WITH SECTOR
destring NAICS, replace
gen int ind3d = NAICS / 1000
gen int ind2d = floor(ind3d / 10)
gen int ind1d = floor(ind3d / 100)

* 1-digit first
rename ind1d naics2017
#delimit ;
merge m:1 naics2017 using "$WFHshared/industries/output/naicsindex2017.dta",
	keepusing(sector) keep(1 3 4) nogen update;
#delimit cr
rename naics2017 ind1d

* 2-digit
rename ind2d naics2017
#delimit ;
merge m:1 naics2017 using "$WFHshared/industries/output/naicsindex2017.dta",
	keepusing(sector) keep(1 3 4) nogen update;
#delimit cr
rename naics2017 ind2d

* 3-digit
rename ind3d naics2017
#delimit ;
merge m:1 naics2017 using "$WFHshared/industries/output/naicsindex2017.dta",
	keepusing(sector) keep(1 3 4) nogen update;
#delimit cr
rename naics2017 ind3d

* Replace ** with missing
#delimit ;
local stringvars
	TOT_EMP PCT_TOTAL H_MEAN H_MEDIAN
	A_MEAN A_MEDIAN;
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
save "$OESout/oes_cleaned.dta", replace
