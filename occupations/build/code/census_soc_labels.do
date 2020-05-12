/* --- HEADER ---
This script creates do-files with value labels for SOC
occupation categories at the 2- and 3-digit level.
*/

args occyear

clear

local socpath "build/input/soc`occyear'.txt"
infix str socstr 1-7 str slabel 8-100 using "`socpath'"

replace slabel = strtrim(slabel)
replace socstr = strtrim(socstr)

// CREATE CATEGORIES
sort socstr

* 2-digit
gen soc2 = substr(socstr, 1, 2)
destring soc2, replace
label variable soc2 "Occupation, major"

* 3-digit
tempvar soc3_1 soc3_2 soc5_2
gen `soc3_1' = substr(socstr, 1, 2)
gen `soc3_2' = substr(socstr, 4, 1)
gen `soc5_2' = substr(socstr, 4, 3)
gen soc3 = `soc3_1' + `soc3_2'
destring soc3, replace
gen soc5 = `soc3_1' + `soc5_2'
destring soc5, replace
label variable soc3 "Occupation, minor"
label variable soc5 "Occupation, broad"

drop `soc3_1' `soc3_2' `soc5_2'

// LABEL CATEGORIES
* Tag headers
bysort soc2 (socstr): gen header2 = (_n == 1)
bysort soc3 (socstr): gen header3 = (_n == 1) if !header2
bysort soc5 (socstr): gen header5 = (_n == 1) if (!header2 & !header3)
replace header3 = 0 if (header3 != 1)
replace header5 = 0 if (header5 != 1)

* 2-digit
tempvar d2one d2all
bysort soc2 (socstr): gen `d2one' = slabel if header2
bysort soc2 (socstr `d2one'): gen `d2all' = `d2one'[1]

* 3-digit
tempvar d3one d3all
bysort soc3 (socstr): gen `d3one' = slabel if header3
bysort soc3 (socstr `d3one'): gen `d3all' = `d3one'[1]
replace soc3 = . if header2

* 5-digit
tempvar d5one d5all
bysort soc5 (socstr): gen `d5one' = slabel if header5
bysort soc5 (socstr `d5one'): gen `d5all' = `d5one'[1]
replace soc5 = . if header2 | header3

sort socstr
drop if soc2 >= 55

local lab5d "build/output/soc5dlabels`occyear'.do"
local lab3d "build/output/soc3dlabels`occyear'.do"
local lab2d "build/output/soc2dlabels`occyear'.do"
local vals5d "build/output/soc5dvalues`occyear'.dta"
local vals3d "build/output/soc3dvalues`occyear'.dta"
local vals2d "build/output/soc2dvalues`occyear'.dta"
local digits 2 3 5
foreach d of local digits {
	* Save list of occupation codes and labels
	preserve
	keep soc`d' `d`d'all'
	rename soc`d' soc`d'd`occyear'
	duplicates drop
	drop if missing(soc`d'd`occyear')
	
	labmask soc`d'd`occyear', values(`d`d'all') lblname(soc`d'd`occyear'_lbl)
	drop `d`d'all'
	
	#delimit ;
	label save soc`d'd`occyear'_lbl using "`lab`d'd'", replace;
	#delimit cr

	save "`vals`d'd'", replace
	restore
}
