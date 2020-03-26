clear

label define bin_lbl 0 "No" 1 "Yes", replace

* Read data after coding missing values
use "$build/temp/acs_temp.dta", clear

* Nominal wage income
gen nincwage = incwage
label variable nincwage "Wage and salary income, nominal"

* Adjust income to 2018 prices
quietly sum cpi99 if (year == 2018)
local cpi1999_2018 = `r(max)'
gen cpi2018 = cpi99 / `cpi1999_2018'

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

* Recode certain binary variables
#delimit ;
foreach var of varlist
	amindian asian black pacislander
	white otherrace diff* farm
{;
	recode `var' (1 = 0) (2 = 1);
	label values `var' bin_lbl;
};
#delimit cr

label variable farm "Farm worker"

recode metropolitan (2/5 = 1) (6/8 = 0)
label variable metropolitan "Lived in metropolitan area"
label values metropolitan bin_lbl

* Generate 2010 occupation categories
#delimit ;
local occ2010_categories
	10/430 500/730 800/950 1000/1240
	1300/1540 1550/1560 1600/1980
	2000/2060 2100/2150 2200/2550
	2600/2920 3000/3540 3600/3650
	3700/3950 4000/4150 4200/4250
	4300/4650 4700/4965 5000/5940
	6005/6130 6200/6765 6800/6940
	7000/7630 7700/8965 9000/9750
	9800/9830;
#delimit cr

gen occupation = occ2010
local occrecode
forvalues i = 1/26 {
	local occrange `: word `i' of `occ2010_categories''
	local occrecode `occrecode' (`occrange' = `i')
}
recode occupation `occrecode'

label variable occupation "Occupation, 26 categories aggregated from OCC2010"
label define occupation_lbl 1 "Management, Business, Science, and Arts"
label define occupation_lbl 2 "Business Operations Specialists", add
label define occupation_lbl 3 "Financial Specialists", add
label define occupation_lbl 4 "Computer and Mathematical", add
label define occupation_lbl 5 "Architecture and Engineering", add
label define occupation_lbl 6 "Technicians", add
label define occupation_lbl 7 "Life, Physical, and Social Science", add
label define occupation_lbl 8 "Community and Social Services", add
label define occupation_lbl 9 "Legal", add
label define occupation_lbl 10 "Education, Training, and Library", add
label define occupation_lbl 11 "Arts, Design, Entertainment, Sports, and Media", add
label define occupation_lbl 12 "Healthcare Practitioners and Technicians", add
label define occupation_lbl 13 "Healthcare Support", add
label define occupation_lbl 14 "Protective Service", add
label define occupation_lbl 15 "Food Preparation and Serving", add
label define occupation_lbl 16 "Building and Grounds Cleaning and Maintenance", add
label define occupation_lbl 17 "Personal Care and Service", add
label define occupation_lbl 18 "Sales and Related", add
label define occupation_lbl 19 "Office and Administrative Support", add
label define occupation_lbl 20 "Farming, Fishing, and Forestry", add
label define occupation_lbl 21 "Construction", add
label define occupation_lbl 22 "Extraction", add
label define occupation_lbl 23 "Installation, Maintenance, and Repair", add
label define occupation_lbl 24 "Production", add
label define occupation_lbl 25 "Transportation and Material Moving", add
label define occupation_lbl 26 "Military Specific", add
label values occupation occupation_lbl

* Generate education categories
gen education = .
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
gen agecat = .
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

* Other variables
gen race = .
replace race = 1 if (white == 1)
replace race = 2 if (black == 1)
replace race = 3 if (asian == 1)
replace race = 4 if (amindian == 1) | (pacislander == 1) | (otherrace == 1)
label variable race "Race, aggregated"
label define race_lbl 1 "White" 2 "Black" 3 "Asian" 4 "Other"
label values race race_lbl

recode inschool (1 = 0) (2 = 1)
label values inschool inschool bin_lbl

recode veteran (1 = 0) (2 = 1)
label values veteran bin_lbl

recode hashealthins (1 = 0) (2 = 1)
label values hashealthins bin_lbl

gen married = inlist(marst, 1, 2) if !missing(marst)
label variable married "Currently married"
label values married bin_lbl

gen hispanic = inlist(hispan, 1, 2, 3, 4) if !missing(hispan)
replace hispanic = . if (hispan == 9)
label variable hispanic "Of Hispanic origin"
label values hispanic bin_lbl

gen employed = (empstat == 1) if !missing(empstat)
label variable employed "Currently employed"
label values employed bin_lbl

gen armedforces = inrange(empstatd, 3, 5) if !missing(empstatd)
label variable armedforces "Member of the armed forces"
label values armedforces bin_lbl

gen selfemployed = (classwkr == 1) if !missing(classwkr)
label variable selfemployed "Self-employed worker"
label values selfemployed bin_lbl

gen govworker = inlist(classwkrd, 24, 25, 27, 28) if !missing(classwkrd)
label variable govworker "Government worker"
label values govworker bin_lbl

gen workfromhome = (tranwork == 70) if !missing(tranwork)
label variable workfromhome "Worked from home"
label values workfromhome bin_lbl

gen stemdegree = inlist(degfield, 13 24 25 36 37 50/52 56/59 61)
replace stemdegree = 0 if (bs_or_higher != 1)
replace stemdegree = . if missing(degfield, bs_or_higher)
label variable stemdegree "BS or higher and degree field is STEM-related"
label values stemdegree bin_lbl

gen work_live_same_metarea = (workplace_metro == residence_metro) if !missing(workplace_metro, residence_metro)
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
drop if missing(workfromhome)

gen fulltime = (uhrswork >= 34)
label variable fulltime "Worked at least 34 hrs per week"
label values fulltime bin_lbl

// WAGE QUINTILES

gen wage_quintile = .
forvalues yr = 2000/2018 {
	count if (year == `yr')
	if `r(N)' > 5 {
		xtile tmp = incwage [pw=perwt] if (year == `yr'), nq(5)
		replace wage_quintile = tmp if (year == `yr')
		drop tmp
	}
}
label variable wage_quintile "Wage quintile within the given year"

drop hispan diff* armedforces employed

* Hourly wage
gen hrwage = incwage / uhrswork
label variable hrwage "Hourly wage, incwage/uhrswork"

* 3-digit occupation coding
#delimit ;
merge m:1 occn year using "$maindir/other/occindex.dta",
	keepusing(occfine) keep(match master) nogen;
#delimit cr

save "$build/cleaned/acs_cleaned.dta", replace
// COMPUTE MEDIAN, MEAN WAGES FOR EACH OCCUPATION, THREE DIGIT OCC
drop if year < 2018
#delimit ;
collapse (median) medwage3digit=incwage (mean) meanwage3digit=incwage
	[iw=perwt], by(occfine) fast;
#delimit cr
gen year = 2018
tempfile wagetmp
save `wagetmp'

use "$build/cleaned/acs_cleaned.dta", clear

#delimit ;
merge m:1 year occfine using `wagetmp',
	keepusing(medwage3digit meanwage3digit) nogen;
#delimit cr

compress
save "$build/cleaned/acs_cleaned.dta", replace
// COMPUTE MEDIAN, MEAN WAGES FOR EACH OCCUPATION, BROADER OCC
drop if year < 2018
#delimit ;
collapse (median) medwage2digit=incwage (mean) meanwage2digit=incwage
	[iw=perwt], by(year occupation) fast;
#delimit cr
gen year = 2018

save `wagetmp', replace
use "$build/cleaned/acs_cleaned.dta", clear

#delimit ;
merge m:1 year occupation using `wagetmp',
	keepusing(medwage2digit meanwage2digit) nogen;
#delimit cr

// * Median wage for each metro area
// bysort year workplace_metro: egen area_medwage = median(incwage)
// label variable area_medwage "Median wage, unweighted, for metro-yr"

// * Merge metropolitan area rent figures
// #delimit ;
// merge m:1 year workplace_metro using "$build/cleaned/acs_rents.dta",
// 	keepusing(rent25 rent50 rent75) nogen;
// rename rent25 work_rent25;
// rename rent50 work_rent50;
// rename rent75 work_rent75;
//
// merge m:1 year residence_metro using "$build/cleaned/acs_rents.dta",
// 	keepusing(rent25 rent50 rent75) nogen;
// rename rent25 home_rent25;
// rename rent50 home_rent50;
// rename rent75 home_rent75;
// #delimit cr

compress
capture mkdir "$build/cleaned"
save "$build/cleaned/acs_cleaned.dta", replace
