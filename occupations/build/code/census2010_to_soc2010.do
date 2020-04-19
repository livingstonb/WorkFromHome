/* --- HEADER ---
This script creates crosswalks for occupation codes.
*/

* Use crosswalk between CENSUS2010 and SOC2010
`#PREREQ' local cwalk "build/input/census2010_to_soc2010.csv"
import delimited "`cwalk'", clear bindquotes(strict)
rename soc socstr

drop if missing(census)
replace socstr = strtrim(socstr)

tempvar s1 s2
gen `s1' = substr(socstr, 1, 2)
gen `s2' = substr(socstr, 4, 1)
gen soc3d2010 = `s1' + `s2'
destring soc3d2010, replace force
drop socstr

gen soc2d2010 = floor(soc3d2010 / 10)

`#PREREQ' quietly do "build/output/soc3dlabels2010.do"
label values soc3d2010 soc3d2010_lbl

`#PREREQ' quietly do "build/output/soc2dlabels2010.do"
label values soc2d2010 soc2d2010_lbl

drop if census >= 9800
keep census soc3d2010 soc2d2010

label variable soc3d2010 "Occupation, 3-digit"
label variable soc2d2010 "Occupation, 2-digit"
rename census census2010

`#TARGET' local final "build/output/census2010_to_soc2010.dta"
save "`final'", replace