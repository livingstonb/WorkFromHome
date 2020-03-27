// CLEAN MERGED DATASET

cd "$datadir"
capture mkdir "cleaned"
use "temp/merged.dta", clear

drop if missing(leavemod)
drop leavemod

label define bin_lbl 0 "No" 1 "Yes"

* Code missings
#delimit ;
foreach var of varlist
	ptdtrace lujf* lejf* pehspnon
	peeduca trdpftpt trhhchild
	teio1cow trmjocc1 trmjind1
	trernhly temjot tryhhchild
	teio1ocd {;
	recode `var' (-3 -2 -1 = .);
};
#delimit cr

* Rename variables
rename lufinlwgt leavewt
rename tufinlwgt atuswt
rename tucaseid id
rename teage age
rename lejf_1 flexhours
rename lejf_11 doeswfh
rename lejf_12 paidwfh
rename lejf_14 daysonlywfh
rename lejf_15 freqwfh
rename lujf_10 canwfh
rename tesex sex
rename ptdtrace orig_race
rename pehspnon hispanic
rename peeduca orig_education
rename trchildnum nchildren
rename trhhchild haschild
rename tryhhchild youngestchild
rename tehrusl1 uhrsworked1
rename tehrusl2 uhrsworked2
rename tehruslt uhrsworkedt
rename teio1cow classwkr1
rename trmjocc1 occupation
rename teio1ocd occ3digit
rename trmjind1 industry
rename trernhly earnhr
rename trernwa earnwk
rename trdpftpt fulltime
rename temjot multjob
rename tuyear year

* 3-digit occupation
merge 1:

* Age groups
gen int agecat = .
replace agecat = 15 if inrange(age, 15, 24)
replace agecat = 25 if inrange(age, 25, 34)
replace agecat = 35 if inrange(age, 35, 44)
replace agecat = 45 if inrange(age, 45, 54)
replace agecat = 55 if inrange(age, 55, 64)
replace agecat = 65 if (age >= 65) & !missing(age)
label variable agecat "Age group"
label define agecat_lbl 15 "15-24 years"
label define agecat_lbl 25 "25-34 years", add
label define agecat_lbl 35 "35-44 years", add
label define agecat_lbl 45 "45-54 years", add
label define agecat_lbl 55 "55-64 years", add
label define agecat_lbl 65 "65+ years", add
label values agecat agecat_lbl

* Education groups
gen byte education = .
replace education = 1 if (orig_educ <= 38)
replace education = 2 if (orig_educ == 39)
replace education = 3 if inrange(orig_educ, 40, 42)
replace education = 4 if (orig_educ >= 43)
replace education = . if missing(orig_educ)
replace education = . if (age < 25)

label variable education "Educational attainment (25 years and over)"
label define education_lbl 1 "Less than a high school diploma"
label define education_lbl 2 "High school graduates, no college", add
label define education_lbl 3 "Some college or associate degree", add
label define education_lbl 4 "Bachelor's degree or higher", add
label values education education_lbl

* Recoded race
gen byte race = .
replace race = 1 if (orig_race == 1)
replace race = 2 if (orig_race == 2)
replace race = 3 if (orig_race == 4)
label variable race "Race if only one listed, 3 categories"
label define race_lbl 1 "White" 2 "Black or African American" 3 "Asian"
label values race race_lbl

* Other recodes
recode canwfh (2 = 0)
label values canwfh bin_lbl

recode hispanic (2 = 0)
label values hispanic bin_lbl

recode doeswfh (2 = 0)
replace doeswfh = 0 if (canwfh == 0)
label values doeswfh bin_lbl

recode fulltime (2 = 0)
label values fulltime bin_lbl

recode haschild (2 = 0)
label variable haschild "Parent of a household child"
label define haschild_lbl 0 "Not a parent of a household child under 18 yrs"
label define haschild_lbl 1 "Parent of a household child under 18 yrs", add
label values haschild haschild_lbl

label variable occupation "Occupation"
label variable industry "Industry"

replace earnwk = earnwk / 100
replace earnhr = earnhr / 100

recode multjob (2 = 0)
label values multjob bin_lbl

recode flexhours (2 = 0)
label variable flexhours "Work schedule flexibility"
label define flexhours_lbl 1 "Had flexible schedule"
label define flexhours_lbl 0 "Did not have flexible schedule", add
label values flexhours flexhours_lbl

* Other new variables
gen byte sector = .
replace sector = 1 if inrange(classwkr1, 4, 5)
replace sector = 2 if inrange(classwkr1, 1, 3)
label variable sector "Class of worker"
label define sector_lbl 1 "Private sector" 2 "Public sector"
label values sector sector_lbl

gen byte dprivatewkr = 1 if (classwkr1 == 4)
replace dprivatewkr = 2 if (classwkr1 == 5)
label variable dprivatewkr "Class of worker (private only)"
label define dprivatewkr_lbl 1 "Private, for profit" 2 "Private, not for profit"
label values dprivatewkr dprivatewkr_lbl

gen byte dpublicwkr = classwkr1 if inrange(classwkr1, 1, 3)
label variable dpublicwkr "Class of worker (public only)"
label define dpublicwkr_lbl 1 "Federal" 2 "State" 3 "Local"
label values dpublicwkr dpublicwkr_lbl

gen singjob_fulltime = fulltime if (multjob == 0)
label variable singjob_fulltime "Full- and part-time status (single jobholders only)"
label define singjob_fulltime_lbl 0 "Part-time workers" 1 "Full-time workers"
label values singjob_fulltime singjob_fulltime_lbl

xtile y17_earnq = earnwk [pw=leavewt] if (fulltime == 1) & (year == 2017), nq(4)
xtile y18_earnq = earnwk [pw=leavewt] if (fulltime == 1) & (year == 2018), nq(4)

gen earnq = y17_earnq
replace earnq = y18_earnq if (year == 2018)
drop y17_earnq y18_earnq

replace earnq = . if (multjob == 1)

label variable earnq "Usual wkly earnings of full-time workers (single jobholders only)"
label define earnq_lbl 1 "Earnings less than or equal to 25th pctile"
label define earnq_lbl 2 "Earnings from 25th to 50th pctiles", add
label define earnq_lbl 3 "Earnings from 50th to 75th pctiles", add
label define earnq_lbl 4 "Earnings greater than the 75th pctile", add
label values earnq earnq_lbl

gen hasyoungchild = .
replace hasyoungchild = 1 if inrange(youngestchild, 0, 12)
replace hasyoungchild = 2 if inrange(youngestchild, 13, 17)
label variable hasyoungchild "Parent of a household child"
label define hasyoungchild_lbl 1 "Parent of a child under 13 years"
label define hasyoungchild_lbl 2 "Parent of a child 13 to 17 years (none younger)", add
label values hasyoungchild hasyoungchild_lbl

compress
save "cleaned/ATUS_cleaned.dta", replace

