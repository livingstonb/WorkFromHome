/* --- HEADER ---
Creates a crosswalk from 1998 SOC codes to 3-digit SOC 2010 codes (occ3d2010).
*/

* Read raw dataset
`#PREREQ' use if (year == 2000) using "../ACS/build/input/acs_raw.dta", clear
keep occsoc occ2010

* Clean occsoc
replace occsoc = strtrim(occsoc)
replace occsoc = "" if occsoc == "0"
drop if occsoc == ""

* Recode statisticians
recode occ2010 (1230 = 1240)

* Check mapping between occsoc and soc3d2010
`#PREREQ' local cwalk "build/output/occ2010_to_soc3d2010.dta"
merge m:1 occ2010 using "`cwalk'", keepusing(soc3d2010) keep(1 3)

* Check uniformity of soc3d2010 within occsoc
bysort occsoc: egen soc3dmin = min(soc3d2010)
bysort occsoc: egen soc3dmax = max(soc3d2010)
gen matched = (soc3dmin == soc3dmax) & !missing(soc3dmin)
drop if !matched

* Drop duplicates
duplicates drop occsoc soc3d2010, force

* Replace X's to match with broad categories
gen occadj = occsoc
replace occadj = substr(occsoc, 1, 5) if substr(occsoc, 6, 1) == "0"
replace occadj = substr(occsoc, 1, 4) if substr(occsoc, 5, 2) == "00"
replace occadj = substr(occsoc, 1, 3) if substr(occsoc, 4, 3) == "000"
replace occadj = subinstr(occadj, "X", "", .)
replace occadj = subinstr(occadj, "Y", "", .)
destring occadj, replace force
drop occsoc
rename occadj occsoc

duplicates drop occsoc soc3d2010, force
keep occsoc soc3d2010

label data "Crosswalk from SOC1998 TO SOC2010-3"
`#TARGET' save "build/output/soc98_to_soc3d2010.dta", replace
