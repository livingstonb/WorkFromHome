/*
Creates a crosswalk from OES99 codes to 3-digit SOC2010 categories, using both
an OES99-SOC98 crosswalk and a SOC98-SOC3D2010 crosswalk.
*/

clear
import excel "build/input/oes99_to_soc98.xls", firstrow

foreach var of varlist * {
	replace `var' = strtrim(`var')
}
destring oescode, force replace

* OES to soc3d2010
gen soc6d = subinstr(soccode, "-", "", .)
gen soc3d = substr(soc6d, 1, 3)
gen soc4d = substr(soc6d, 1, 4)
gen soc5d = substr(soc6d, 1, 5)

local cw98 "../occupations/build/output/soc98_to_soc3d2010.dta"
forvalues d = 6(-1)3 {
	destring soc`d'd, force replace
	rename soc`d'd occsoc
	merge m:1 occsoc using "`cw98'", nogen keepusing(soc3d2010) keep(1 3 4) update
	drop occsoc
}

replace soc3d2010 = 119 if soccode == "13-1061"
replace soc3d2010 = 152 if soccode == "15-3011"
replace soc3d2010 = 191 if soccode == "19-1099"
replace soc3d2010 = 493 if soccode == "49-3013"
replace soc3d2010 = 515 if soccode == "51-5099"
replace soc3d2010 = 513 if soccode == "51-3099"
replace soc3d2010 = 532 if soccode == "53-2099"
replace soc3d2010 = 435 if soccode == "43-5199"
replace soc3d2010 = 171 if soccode == "17-1099"

* OES99 to soc3d2010, use only OES codes that can be uniquely tied to an occupation
drop if inlist(oes99code, "", "na.", "na")
drop if strpos(oes99code, "9099") > 0
drop if missing(soccode)

* Mapping is now one or more OES99 to one soc3d2010
duplicates drop oes99code, force
keep soc3d2010 oes99code

label data "Crosswalk from OES99 to SOC2010-3"
save "build/output/oes99_to_soc3d2010.dta", replace
