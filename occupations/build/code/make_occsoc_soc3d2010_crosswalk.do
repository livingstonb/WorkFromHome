
* Read raw dataset
`#PREREQ' use if (year == 2000) using "build/input/acs_raw.dta", clear
keep occsoc occ2010

* Clean occsoc
replace occsoc = strtrim(occsoc)
replace occsoc = "" if occsoc == "0"
drop if occsoc == ""

* Recode statisticians
recode occ2010 (1230 = 1240)

* Check mapping between occsoc and soc3d2010
`#PREREQ' local cwalk "../occupations/build/output/cwalk_acs_occ2010_soc3d2010.dta"
merge m:1 occ2010 using "`cwalk'", keepusing(soc3d2010) keep(1 3)

* Check uniformity of soc3d2010 within occsoc
bysort occsoc: egen soc3dmin = min(soc3d2010)
bysort occsoc: egen soc3dmax = max(soc3d2010)
gen matched = (soc3dmin == soc3dmax) & !missing(soc3dmin)
drop if !matched

* Drop duplicates
duplicates drop occsoc soc3d2010, force

* Replace X's to match with broad categories
replace occsoc = subinstr(occsoc, "X", "", .)
replace occsoc = subinstr(occsoc, "Y", "", .)
destring occsoc, replace force

duplicates drop occsoc soc3d2010, force
keep occsoc soc3d2010

`#TARGET' save "build/output/cwalk_occsoc_soc3d2010.dta"
