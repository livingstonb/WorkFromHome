#delimit ;
foreach var of varlist inctot incbus00 incss
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
	amindian asian black pacislander hashealthins
	white otherrace farm veteran inschool
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

gen byte govworker = inlist(classwkrd, 24, 25, 27, 28) if !missing(classwkrd)
label variable govworker "Government worker"
label values govworker bin_lbl

gen byte stemdegree = inlist(degfield, 13 24 25 36 37 50/52 56/59 61)
replace stemdegree = 0 if (bs_or_higher != 1)
replace stemdegree = . if missing(degfield, bs_or_higher)
label variable stemdegree "BS or higher and degree field is STEM-related"
label values stemdegree bin_lbl

gen byte work_live_same_metarea = (workplace_metro == residence_metro) if !missing(workplace_metro, residence_metro)
label variable work_live_same_metarea "Res and work are in same metro area"
label values work_live_same_metarea bin_lbl

* Recode certain binary variables
#delimit ;
foreach var of varlist diff* {;
	recode `var' (1 = 0) (2 = 1);
	label values `var' bin_lbl;
};
#delimit cr

gen workdifficulty = 0
foreach var of varlist diff* {
	replace workdifficulty = 1 if (`var' == 1)
}
label variable workdifficulty "Reported a health difficulty"
label values workdifficulty bin_lbl