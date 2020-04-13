/* --- HEADER ---
Computes employment and mean wage by occupation.

#PREREQ "../occupations/build/output/soc3d_2000_to_2010_crosswalk.dta"
#PREREQ "build/output/oes2d2000.dta"
#PREREQ "build/output/oes2d2001.dta"
#PREREQ "build/output/oes4d2002.dta"
#PREREQ "build/output/oes3d2003.dta"
#PREREQ "build/output/oes2d2004.dta"
#PREREQ "build/output/oes2d2005.dta"
#PREREQ "build/output/oes2d2006.dta"
#PREREQ "build/output/oes2d2007.dta"
#PREREQ "build/output/oes2d2008.dta"
#PREREQ "build/output/oes2d2009.dta"
#PREREQ "build/output/oes2d2010.dta"
#PREREQ "build/output/oes2d2012.dta"
#PREREQ "build/output/oes2d2013.dta"
#PREREQ "build/output/oes2d2014.dta"
#PREREQ "build/output/oes2d2015.dta"
#PREREQ "build/output/oes2d2016.dta"
#PREREQ "build/output/oes2d2017.dta"
*/

args year

if (`year' >= 2000) & (`year' < 2010) {
	local socvar soc3d2000
}
else if (`year' >= 2010) & (`year' <= 2017) {
	local socvar soc3d2010
}

if (`year' == 2002) {
	local digit 4
}
else if (`year' == 2003) {
	local digit 3
}
else {
	local digit 2
}

* Read raw data
if (`year' <= 2002 ) {
	use "build/output/oes`digit'd`year'.dta", clear
	rename occ_code OCC_CODE
	rename tot_emp TOT_EMP
	rename a_mean A_MEAN
	
	replace OCC_CODE = strtrim(OCC_CODE)
	gen suffix = substr(OCC_CODE, 3, .)

	capture drop group
	gen OCC_GROUP = ""
	replace OCC_GROUP = "aggregate" if (suffix == "0000")
}
else  {
	use "build/output/oes`digit'd`year'.dta", clear
}
capture rename GROUP OCC_GROUP

* Replace ** with missing
rename TOT_EMP employment
rename A_MEAN meanwage
destring employment, force replace
destring meanwage, force replace
drop if missing(employment, meanwage)

if (`year' <= 2011) {
	drop if OCC_GROUP != ""
}
else {
	keep if OCC_GROUP == "minor"
}
keep employment OCC_CODE meanwage

gen `socvar' = substr(OCC_CODE, 1, 4)
replace `socvar' = subinstr(`socvar', "-", "", .)
destring `socvar', replace

if (`year' >= 2000) & (`year' < 2010) {
	rename OCC_CODE soc2000
	#delimit ;
	merge m:1 soc2000 using 
		"../occupations/build/output/soc3d_2000_to_2010_crosswalk.dta",
		keepusing(soc3d2010) nogen keep(1 3);
	#delimit cr
	drop `socvar'
}
drop if missing(soc3d2010)

gen ones = 1
#delimit ;
collapse (mean) meanwage (sum) employment=ones [iw=employment],
	by(soc3d2010);
#delimit cr

`#PREREQ' do "../occupations/build/output/occ3labels2010.do"
label values soc3d2010 soc3d2010_lbl


keep soc3d2010 employment meanwage


`#TARGET' save "stats/output/summary_by_occupation_`year'.dta", replace
