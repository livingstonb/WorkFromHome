/* --- HEADER ---
Performs cleaning and generates new variables for
the ACS.
*/

`#' args extra_variables

clear
capture label define bin_lbl 0 "No" 1 "Yes"

* Read data after coding missing values
`#PREREQ' local tempinput "build/temp/acs_temp.dta"
use if (year >= 2013) using "`tempinput'" , clear

* Nominal wage income
gen nincwage = incwage
label variable nincwage "Wage and salary income, nominal"

* Adjust income to 2018 prices
quietly sum cpi99 if (year == 2018)
local cpi1999_2018 = `r(max)'
gen cpi2018 = cpi99 / `cpi1999_2018'
drop cpi99

replace incwage = incwage * cpi2018

if "`extra_variables'" == "1" {
	* Not used
	do "build/code/clean_acs_extravars.do"
}

* Other variables
gen byte employed = (empstat == 1) if !missing(empstat)
label variable employed "Currently employed"
label values employed bin_lbl

gen byte armedforces = inrange(empstatd, 3, 5) if !missing(empstatd)
label variable armedforces "Member of the armed forces"
label values armedforces bin_lbl

gen byte selfemployed = (classwkr == 1) if !missing(classwkr)
label variable selfemployed "Self-employed worker"
label values selfemployed bin_lbl

drop empstat* classwkr*

gen byte workfromhome = (tranwork == 70) if !missing(tranwork)
label variable workfromhome "Worked from home"
label values workfromhome bin_lbl

// DEFINITION OF A WORKER
drop if (armedforces == 1) | missing(armedforces)
drop if (incwage < 1000) | missing(incwage)
drop if (wkswork2 < 3) | missing(wkswork2)
drop if (uhrswork == 0) | missing(uhrswork)

gen fulltime = (uhrswork >= 34)
label variable fulltime "Worked at least 34 hrs per week"
label values fulltime bin_lbl

drop armedforces employed wkswork2

// // WAGE QUINTILES
//
// gen wage_quintile = .
// forvalues yr = 2000/2018 {
// 	count if (year == `yr')
// 	if `r(N)' > 5 {
// 		xtile tmp = incwage [pw=perwt] if (year == `yr'), nq(5)
// 		replace wage_quintile = tmp if (year == `yr')
// 		drop tmp
// 	}
// }
// label variable wage_quintile "Wage quintile within the given year"

* Hourly wage
gen hrwage = incwage / uhrswork
label variable hrwage "Hourly wage, incwage/uhrswork"

* 3-digit occupation coding
gen census2010 = occn if inrange(year, 2000, 2017)
gen census2018 = occn if (year > 2017)

* 2012 - 2017
`#PREREQ' local occ2010 "../occupations/build/output/census2010_to_soc2010.dta"
#delimit ;
merge m:1 census2010 using "`occ2010'",
	keepusing(soc3d2010 soc2d2010) keep(1 3) nogen;
#delimit cr
rename soc3d2010 occ3d2010

* 2018
* local occ2018 "../occupations/build/output/census2010_to_soc2010.dta"
* #delimit ;
* merge m:1 census2018 using "`occ2018'",
* 	keepusing(soc3d2010) keep(1 3) nogen;
* #delimit cr
* replace occ3d2010 = soc3d2010 if (year > 2017)
* drop census2018

drop census2010

* Industry coding
gen ind2012 = industry if inrange(year, 2013, 2017)
gen ind2017 = industry if (year > 2017)

`#PREREQ'  local c12 "../industries/build/output/census2012_to_sector.dta"
#delimit ;
merge m:1 ind2012 using "`c12'",
	keepusing(sector) keep(1 3) nogen;
#delimit cr

local c17 "../industries/build/input/census2017_to_sector.dta"
#delimit ;
merge m:1 ind2017 using "`c17'",
	keepusing(sector) keep(1 3 4) nogen update;
#delimit cr

drop ind2012 ind2017

compress
`#TARGET' save "build/output/acs_cleaned.dta", replace