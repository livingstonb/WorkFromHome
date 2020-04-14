/* --- HEADER ---
This do-file cleans the OES dataset at the 3-digit occupation level.
*/

* Read raw data
import excel "build/input/nat3d2017", clear firstrow

drop if inlist(OCC_GROUP, "major", "total", "detailed")
gen soc3d2010 = substr(OCC_CODE, 1, 4)
replace soc3d2010 = subinstr(soc3d2010, "-", "", .)
destring soc3d2010, replace force

gen occ_broad = OCC_CODE if OCC_GROUP == "broad"

gen minors = (OCC_GROUP == "minor")
bysort soc3d2010: egen minor_present = max(minors)

drop if (OCC_GROUP == "broad") & minor_present
drop minors minor_present

`#PREREQ' do "../occupations/build/output/occ3labels2010.do"
label values soc3d2010 soc3d2010_lbl

// MERGE WITH SECTOR
destring NAICS, replace
gen int ind3d = NAICS / 1000
gen int ind2d = floor(ind3d / 10)
gen int ind1d = floor(ind3d / 100)

`#PREREQ' local naicsdta "../industries/build/output/naicsindex2017.dta"

* 1-digit first
rename ind1d naics2017
#delimit ;
merge m:1 naics2017 using "`naicsdta'",
	keepusing(sector) keep(1 3 4) nogen update;
#delimit cr
rename naics2017 ind1d

* 2-digit
rename ind2d naics2017
#delimit ;
merge m:1 naics2017 using "`naicsdta'",
	keepusing(sector) keep(1 3 4) nogen update;
#delimit cr
rename naics2017 ind2d

* 3-digit
rename ind3d naics2017
#delimit ;
merge m:1 naics2017 using "`naicsdta'",
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
`#TARGET' local outpath "build/output/oes3d_cleaned.dta"
save "`outpath'", replace
