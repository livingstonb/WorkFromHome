/* --- HEADER ---
This script creates crosswalks for occupation codes.
*/
args crosswalk
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

if ("`crosswalk'" == "SIPP") {
	rename v1 census
	rename v2 socstr
	drop if (_n == 1)
	replace socstr = strtrim(socstr)
	replace census = strtrim(census)
	drop if strlen(socstr) > 7
	drop if strlen(census) > 4
	destring census, replace
}
else if "`crosswalk'" == "2010" {
	rename soc socstr
	replace socstr = strtrim(socstr)
}
else if "`crosswalk'" == "2018" {
	rename soc socstr
	replace socstr = strtrim(socstr)
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
destring soc3, replace force
drop socstr

`#PREREQ' do "build/output/occ3labels2010.do"
label values soc3 soc3d2010_lbl

`#PREREQ' merge m:1 soc3 using "build/temp/occ_soc_2010.dta", nogen

drop if census >= 9800
keep census soc3 soc2
gen occyear = `occyear'

label variable soc3 "Occupation, 3-digit"
label variable soc2 "Occupation, 2-digit"

rename soc3 soc3d2010
rename soc2 soc2d2010
rename census census`occyear'

`#TARGET' local output "build/output/occindex`crosswalk'.dta"
save "`output'", replace
