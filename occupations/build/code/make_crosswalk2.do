/* --- HEADER ---
This script creates crosswalks for occupation codes.

#PREREQ "build/temp/occ_soc_2010.dta"
#PREREQ "build/temp/occ_soc_2018.dta"
#PREREQ "build/output/occ3labels2010.do"
#PREREQ "build/output/occ3labels2018.do"
*/
args crosswalk
local crosswalk SIPP
clear

if "`crosswalk'" == "2010" {
	local occyear 2010
	local sipp 0
}
else if "`crosswalk'" == "2018" {
	local occyear 2018
	local sipp 0
}
else if "`crosswalk'" == "SIPP" {
	local occyear 2010
	local sipp 1
}


// USE CENSUS-SOC CROSSWALK
clear
`#PREREQ' local fname "build/input/census_soc_crosswalk_`crosswalk'.csv"
import delimited "`fname'", bindquotes(strict)

if (`occyear' == 2018) | ("`sipp'" == "1") {
	rename v1 census
	rename v2 socstr
	drop if (_n == 1)
	replace socstr = strtrim(socstr)
	replace census = strtrim(census)
	drop if strlen(socstr) > 7
	drop if strlen(census) > 4
	destring census, replace
}
else if `occyear' == 2010 {
	rename soc socstr
}

drop if missing(census)
replace socstr = strtrim(socstr)

tempvar s1 s2
gen `s1' = substr(socstr, 1, 2)
gen `s2' = substr(socstr, 4, 1)
gen soc3 = `s1' + `s2'

if "`sipp'" == "1" {	
	replace soc3 = "472" if soc3 == "47X"
}
destring soc3, replace
drop socstr

do "build/output/occ3labels`occyear'.do"
label values soc3 soc3d`occyear'_lbl

merge m:1 soc3 using "build/temp/occ_soc_`occyear'.dta", nogen

drop if census >= 9800
keep census soc3 soc2
gen occyear = `occyear'

label variable soc3 "Occupation, 3-digit"
label variable soc2 "Occupation, 2-digit"

rename soc3 soc3d`occyear'
rename soc2 soc2d`occyear'
rename census census2010

`#TARGET' local output "build/output/occindex`crosswalk'.dta"
save "`output'", replace
