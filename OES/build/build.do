
clear

import excel using "$OESbuild/input/nat3d_M2017_dl.xlsx", firstrow
save "$OESbuildtemp/oes_raw.dta", replace

// SAVE .csv AS .dta
clear
import delimited using "$WFHshared/ind2017/naics_to_sector.csv", bindquotes(strict)
drop v1
save "$OESbuildtemp/naics_to_sector.dta", replace

// MERGE WITH SECTOR
use "$OESbuildtemp/oes_raw.dta", clear
keep if OCC_GROUP == "minor"

destring NAICS, replace
gen int ind3d = NAICS / 1000
gen int ind2d = floor(ind3d / 10)
gen int ind1d = floor(ind3d / 100)

* 1-digit first
rename ind1d naics2017
#delimit ;
merge m:1 naics2017 using "$OESbuildtemp/naics_to_sector.dta",
	keepusing(sector) keep(1 3 4) nogen update;
#delimit cr
rename naics2017 ind1d

* 2-digit
rename ind2d naics2017
#delimit ;
merge m:1 naics2017 using "$OESbuildtemp/naics_to_sector.dta",
	keepusing(sector) keep(1 3 4) nogen update;
#delimit cr
rename naics2017 ind2d

* 3-digit
rename ind3d naics2017
#delimit ;
merge m:1 naics2017 using "$OESbuildtemp/naics_to_sector.dta",
	keepusing(sector) keep(1 3 4) nogen update;
#delimit cr
rename naics2017 ind3d

* Labels
label define sector_lbl 0 "C" 1 "S"
label values sector sector_lbl
label variable sector "Sector"

* Replace ** with missing
#delimit ;
local stringvars
	TOT_EMP PCT_TOTAL H_MEAN H_MEDIAN
	A_MEAN A_MEDIAN;
#delimit cr
foreach var of local stringvars  {
	replace `var' = "" if inlist(`var', "*", "**")
	destring `var', replace
}

* Housekeeping
#delimit ;
keep NAICS NAICS_TITLE OCC_CODE OCC_TITLE OCC_GROUP
	`stringvars' sector;
#delimit cr

encode OCC_TITLE, gen(occupation)

rename A_MEAN meanwage
label variable meanwage "Mean annual wage"

rename A_MEDIAN medianwage
label variable medianwage "Median annual wage"

rename TOT_EMP employment
label variable employment "Total employment rounded to nearest 10 (excl self-employed)"

rename PCT_TOTAL occshare_industry
label variable occshare_industry "% of industry employment in given occ, provided"

bysort sector occupation: egen emp_occ_sector = total(employment)
label variable emp_occ_sector "Total employment in occupation-sector pair"

bysort sector: egen emp_sector = total(employment)
label variable emp_sector "Total employment in sector"

gen occshare_sector = emp_occ_sector / emp_sector
label variable occshare_sector "Occupation share within sector"
compress

order sector occupation meanwage occshare_sector occshare_industry

save "$OESbuildtemp/oes_occ_sector.dta", replace

// COLLAPSE TO OCCUPATION-SECTOR LEVEL
use "$OESbuildtemp/oes_occ_sector.dta", clear
gen totemp = 10
collapse (sum) totemp (mean) meanwage [fw=employment], by(sector occupation)
drop if missing(sector)

bysort sector occupation: egen emp_occ_sector = total(totemp)
label variable emp_occ_sector "Total employment in occupation-sector pair"

bysort sector: egen emp_sector = total(totemp)
label variable emp_sector "Total employment in sector"

gen occshare_sector = emp_occ_sector / emp_sector
label variable occshare_sector "Occupation share within sector"

#delimit ;
export excel
	using "$OESout/oes_occ_sector.xlsx",
	replace firstrow(varlabels);
#delimit cr
