/* --- HEADER ---
This script creates crosswalks for occupation codes.
*/
args occyear

clear

`#PREREQ' local socpath "build/input/soc`occyear'.txt"
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

`#TARGET' local lab3d "build/output/soc3dlabels`occyear'.do"
`#TARGET' local lab2d "build/output/soc2dlabels`occyear'.do"
forvalues d = 2/3 {
	#delimit ;
	label save soc`d'd`occyear'_lbl using "`lab`d'd'", replace;
	#delimit cr
}