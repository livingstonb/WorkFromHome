/* --- HEADER ---
This script creates crosswalks from 2010 or 2018 Census occupation codes
to 2- and 3-digit SOC 2010 categories.
*/

args censusyear

* Use crosswalk between CENSUS2010 and SOC2010
local cwalk "build/input/yr`censusyear'_census_to_soc.csv"
import delimited "`cwalk'", clear bindquotes(strict)
rename soc socstr

drop if missing(census)
replace socstr = strtrim(socstr)

tempvar s1 s2
gen `s1' = substr(socstr, 1, 2)
gen `s2' = substr(socstr, 4, 1)
gen soc3d2010 = `s1' + `s2'
destring soc3d2010, replace force

gen soc5d2010 = substr(socstr, 1, 6)
replace soc5d2010 = subinstr(soc5d2010, "-", "", .)
destring soc5d2010, replace force
rename socstr soc2010

if (`censusyear' == 2018) {
	replace soc3d2010 = 299 if (census == 1980)
	replace soc3d2010 = 232 if (census == 2862)
	replace soc3d2010 = 399 if (census == 3602)
	replace soc3d2010 = 435 if (census == 9645)
	replace soc3d2010 = 514 if (census == 7905)
	replace soc3d2010 = 537 if (census == 6821)
}

gen soc2d2010 = floor(soc3d2010 / 10)

quietly do "build/output/soc5dlabels2010.do"
label values soc5d2010 soc5d2010_lbl

quietly do "build/output/soc3dlabels2010.do"
label values soc3d2010 soc3d2010_lbl

quietly do "build/output/soc2dlabels2010.do"
label values soc2d2010 soc2d2010_lbl

drop if census >= 9800
keep census soc3d2010 soc2d2010 soc2010 soc5d2010

label variable soc2010 "Occupation, 6-digit"
label variable soc3d2010 "Occupation, 3-digit"
label variable soc2d2010 "Occupation, 2-digit"
rename census census`censusyear'

if `censusyear' == 2018 {
	* 2018 codes at the 6-digit level don't match 2010 closely enough
	drop soc2010
}

`#TARGET' local final "build/output/census`censusyear'_to_soc2010.dta"
save "`final'", replace
