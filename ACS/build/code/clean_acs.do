/* --- HEADER ---
Performs cleaning and generates new variables for
the ACS.
*/

clear
capture label define bin_lbl 0 "No" 1 "Yes"

* Read data after coding missing values
`#PREREQ' local tempinput "build/temp/acs_temp.dta"
use if (year >= 2010) using "`tempinput'" , clear

* Nominal wage income
gen nincwage = incwage
label variable nincwage "Wage and salary income, nominal"

* Adjust income to 2018 prices
quietly sum cpi99 if (year == 2018)
local cpi1999_2018 = `r(max)'
gen cpi2018 = cpi99 / `cpi1999_2018'
drop cpi99

#delimit ;
foreach var of varlist
	inctot incwage incbus00 incss
	incwelfr incinvst incretir incsupp
	incother rentgrs {;
replace `var' = `var' * cpi2018;
local vlab: variable label `var';
local vlab "`vlab', 2018 dollars";
label variable `var' "`vlab'";
};
#delimit cr
compress

* Recode certain binary variables
#delimit ;
foreach var of varlist
	amindian asian black pacislander hashealthins
	white otherrace diff* farm veteran inschool
{;
	recode `var' (1 = 0) (2 = 1);
	label values `var' bin_lbl;
};
#delimit cr
compress

label variable farm "Farm worker"

recode metropolitan (2/5 = 1) (6/8 = 0)
label variable metropolitan "Lived in metropolitan area"
label values metropolitan bin_lbl

* Generate education categories
gen byte education = .
replace education = 1 if inrange(educd_orig, 2, 61)
replace education = 2 if inrange(educd_orig, 62, 64)
replace education = 3 if inrange(educd_orig, 65, 100)
replace education = 4 if inrange(educd_orig, 101, 113)
replace education = 5 if (educd_orig == 114)
replace education = 6 if (educd_orig == 115)
replace education = 7 if (educd_orig == 116)

label variable education "Educational attainment, recoded"
label define education_lbl 1 "Less than high school"
label define education_lbl 2 "High school or GED", add
label define education_lbl 3 "Some college", add
label define education_lbl 4 "Bachelor's degree", add
label define education_lbl 5 "Master's degree", add
label define education_lbl 6 "Professional degree", add
label define education_lbl 7 "PhD", add
label values education education_lbl

gen bs_or_higher = (education >= 4) if !missing(education)
label variable bs_or_higher "Has a bachelor's deg or higher"
label values bs_or_higher bin_lbl

* Generate age groups
gen agecat = age
recode agecat (18/24 = 18) (25/34 = 25) (35/44 = 35) (45/54 = 45)
recode agecat (55/64 = 55) (65/150 = 65)
label define agecat_lbl 18 "18 - 24 years"
label define agecat_lbl 25 "25 - 34 years", add
label define agecat_lbl 35 "35 - 44 years", add
label define agecat_lbl 45 "45 - 54 years", add
label define agecat_lbl 55 "55 - 64 years", add
label define agecat_lbl 65 "65 + years", add
label variable agecat "Age group"
label values agecat agecat_lbl
compress

* Other variables
gen byte race = .
replace race = 1 if (white == 1)
replace race = 2 if (black == 1)
replace race = 3 if (asian == 1)
replace race = 4 if (amindian == 1) | (pacislander == 1) | (otherrace == 1)
label variable race "Race, aggregated"
label define race_lbl 1 "White" 2 "Black" 3 "Asian" 4 "Other"
label values race race_lbl

gen byte married = inlist(marst, 1, 2) if !missing(marst)
label variable married "Currently married"
label values married bin_lbl

gen byte hispanic = inlist(hispan, 1, 2, 3, 4) if !missing(hispan)
replace hispanic = . if (hispan == 9)
label variable hispanic "Of Hispanic origin"
label values hispanic bin_lbl

gen byte employed = (empstat == 1) if !missing(empstat)
label variable employed "Currently employed"
label values employed bin_lbl

gen byte armedforces = inrange(empstatd, 3, 5) if !missing(empstatd)
label variable armedforces "Member of the armed forces"
label values armedforces bin_lbl

gen byte selfemployed = (classwkr == 1) if !missing(classwkr)
label variable selfemployed "Self-employed worker"
label values selfemployed bin_lbl

gen byte govworker = inlist(classwkrd, 24, 25, 27, 28) if !missing(classwkrd)
label variable govworker "Government worker"
label values govworker bin_lbl

gen byte workfromhome = (tranwork == 70) if !missing(tranwork)
label variable workfromhome "Worked from home"
label values workfromhome bin_lbl

gen byte stemdegree = inlist(degfield, 13 24 25 36 37 50/52 56/59 61)
replace stemdegree = 0 if (bs_or_higher != 1)
replace stemdegree = . if missing(degfield, bs_or_higher)
label variable stemdegree "BS or higher and degree field is STEM-related"
label values stemdegree bin_lbl

gen byte work_live_same_metarea = (workplace_metro == residence_metro) if !missing(workplace_metro, residence_metro)
label variable work_live_same_metarea "Res and work are in same metro area"
label values work_live_same_metarea bin_lbl

gen workdifficulty = 0
foreach var of varlist diff* {
	replace workdifficulty = 1 if (`var' == 1)
}
label variable workdifficulty "Reported a health difficulty"
label values workdifficulty bin_lbl

// DEFINITION OF A WORKER
drop if (armedforces == 1) | missing(armedforces)
drop if (incwage < 1000) | missing(incwage)
drop if (wkswork2 < 3) | missing(wkswork2)
drop if (uhrswork == 0) | missing(uhrswork)
// drop if missing(workfromhome)

gen fulltime = (uhrswork >= 34)
label variable fulltime "Worked at least 34 hrs per week"
label values fulltime bin_lbl

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

drop hispan diff* armedforces employed

* Hourly wage
gen hrwage = incwage / uhrswork
label variable hrwage "Hourly wage, incwage/uhrswork"

* 3-digit occupation coding
gen occyear = 2010 if inrange(year, 2010, 2017)
replace occyear = 2018 if (year == 2018)

* 2012 - 2017
`#PREREQ' local occ2010 "../occupations/build/output/occindex2010.dta"
rename occn census2010
#delimit ;
merge m:1 census2010 occyear using "`occ2010'",
	keepusing(soc3d2010 soc2d2010) keep(1 3) nogen;
#delimit cr
rename soc3d2010 occ3d2010

* 2018
`#PREREQ' local occ2018 "../occupations/build/output/occindex2018.dta"
rename census2010 census2018
#delimit ;
merge m:1 census2018 occyear using "`occ2018'",
	keepusing(soc3d2010) keep(1 3 4) nogen update;
#delimit cr
replace occ3d2010 = soc3d2010 if year == 2018

drop occyear soc3d2010
rename census2018 occn

* Industry coding
`#PREREQ' local ind "../industries/build/output/industryindex2012.dta"
rename industry ind2012
#delimit ;
merge m:1 ind2012 using "`ind'",
	keepusing(sector) keep(1 3 4) nogen;
#delimit cr
compress

compress
`#TARGET' save "build/output/acs_cleaned.dta", replace
