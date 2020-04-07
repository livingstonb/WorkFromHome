// NOTE: FIRST RUN "do macros.do" IN THE MAIN DIRECTORY

/* This script creates crosswalks for occupation codes. */
clear

// DECLARE SIPP
local sipp 0

// DECLARE YEAR (2010 OR 2018)
local occyear 2010

// SET OCCYEAR TO 2010 IF SIPP
if `sipp' == 1 {
	local occyear 2010
}

#delimit ;
infix str socstr 1-7 str slabel 8-100
	using "$WFHshared/occupations/input/occ_soc_`occyear'.txt";
#delimit cr

replace slabel = strtrim(slabel)
replace socstr = strtrim(socstr)

// CREATE CATEGORIES
sort socstr

* 2-digit
gen soc2 = substr(socstr, 1, 2)
destring soc2, replace
label variable soc2 "Occupation, major"

* 3-digit
tempvar soc3_1 soc3_2
gen `soc3_1' = substr(socstr, 1, 2)
gen `soc3_2' = substr(socstr, 4, 1)
gen soc3 = `soc3_1' + `soc3_2'
destring soc3, replace
label variable soc3 "Occupation, minor"

// LABEL CATEGORIES
* Tag headers
bysort soc2 (socstr): gen header2 = (_n == 1)
bysort soc3 (socstr): gen header3 = _n if header2 != 1
replace header3 = 0 if (header3 != 1)

* 2-digit
tempvar d2one d2all
bysort soc2 (socstr): gen `d2one' = slabel if header2
bysort soc2 (socstr `d2one'): gen `d2all' = `d2one'[1]
labmask soc2, values(`d2all') lblname(soc2d`occyear'_lbl)

* 3-digit
tempvar d3one d3all
bysort soc3 (socstr): gen `d3one' = slabel if header3
bysort soc3 (socstr `d3one'): gen `d3all' = `d3one'[1]
labmask soc3, values(`d3all') lblname(soc3d`occyear'_lbl)
replace soc3 = . if header2

keep soc*

sort socstr
capture mkdir "$WFHshared/occupations/temp"
if "`sipp'" != "1" {
	#delimit ;
	label save soc3d`occyear'_lbl
		using "$WFHshared/occupations/output/occ3labels`occyear'.do", replace;
	#delimit cr
}

keep soc2 soc3
duplicates drop soc3, force
drop if missing(soc3)
save "$WFHshared/occupations/temp/occ_soc_`occyear'.dta", replace

// USE CENSUS-SOC CROSSWALK
clear

if ("`sipp'" == "1") {
	local fname "census_soc_crosswalk_SIPP"
}
else {
	local fname "census_soc_crosswalk_`occyear'"
}

import delimited "$WFHshared/occupations/input/`fname'.csv", bindquotes(strict)

if (`occyear' == 2018) | ("`sipp'" == "1") {
	rename v1 census
	rename v2 socstr
	drop if (_n == 1)
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

do "$WFHshared/occupations/output/occ3labels`occyear'.do"
label values soc3 soc3

merge m:1 soc3 using "$WFHshared/occupations/temp/occ_soc_`occyear'.dta", nogen

drop if census >= 9800
keep census soc3 soc2
gen occyear = `occyear'

label variable soc3 "Occupation, 3-digit"
label variable soc2 "Occupation, 2-digit"

rename soc3 soc3d`occyear'
rename soc2 soc2d`occyear'

capture mkdir "$WFHshared/occupations/output"

if ("`sipp'" == "1") {
	local fname "occindexSIPP.dta"
}
else {
	local fname "occindex`occyear'.dta"
}
save "$WFHshared/occupations/output/`fname'", replace
