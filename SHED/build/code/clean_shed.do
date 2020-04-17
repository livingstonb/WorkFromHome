/* --- HEADER ---
This do-file cleans the SHED dataset.
*/

adopath + "../ado"

* Resave occupation crosswalk as stata file
clear
`#PREREQ' import delimited "build/input/occ_crosswalk.csv", bindquotes(strict)
label define soclbl 11 "Management Occupations"
label define soclbl 13 "Business and Financial Operations Occupations", add
label define soclbl 15 "Computer and Mathematical Occupations", add
label define soclbl 17 "Architecture and Engineering Occupations", add
label define soclbl 19 "Life, Physical, and Social Science Occupations", add
label define soclbl 21 "Community and Social Service Occupations", add
label define soclbl 23 "Legal Occupations", add
label define soclbl 25 "Education, Training, and Library Occupations", add
label define soclbl 27 "Arts, Design, Entertainment, Sports, and Media Occupations", add
label define soclbl 29 "Healthcare Practitioners and Technical Occupations", add
label define soclbl 31 "Healthcare Support Occupations", add
label define soclbl 33 "Protective Service Occupations", add
label define soclbl 35 "Food Preparation and Serving Related Occupations", add
label define soclbl 37 "Building and Grounds Cleaning and Maintenance Occupations", add
label define soclbl 39 "Personal Care and Service Occupations", add
label define soclbl 41 "Sales and Related Occupations", add
label define soclbl 43 "Office and Administrative Support Occupations", add
label define soclbl 45 "Farming, Fishing, and Forestry Occupations", add
label define soclbl 47 "Construction and Extraction Occupations", add
label define soclbl 49 "Installation, Maintenance, and Repair Occupations", add
label define soclbl 51 "Production Occupations", add
label define soclbl 53 "Transportation and Material Moving Occupations", add
label values soc2d soclbl

tempfile cwalk
save `cwalk', replace

* Prepare sector crosswalk
local naicswalk "cwalk_naics2017_to_sector.dta"
use "../industries/build/input/`naicswalk'", clear
rename sector cvsector

tempfile naics
save `naics', replace

* Read main data file
`#PREREQ' use "build/temp/shed_temp.dta", clear

// RECODE OCCUPATION
#delimit ;
merge m:1 occupation year using `cwalk',
	keep(match master) keepusing(soc2d soc_2d_label) nogen;
#delimit cr
drop soc_2d_label
rename soc2d soc2d2010

`#PREREQ' local acsstats "../ACS/stats/output/acs_stats_for_shed.dta"
#delimit ;
merge m:1 soc2d2010 using "`acsstats'",
	keep(match master) nogen;
#delimit cr
label variable wfhflex "2x2 Occupation"
label define wfhflex_lbl 0 "WFH-Rigid" 1 "WFH-Flexible"
label values wfhflex wfhflex_lbl

// RECODE INDUSTRY AS C/S SECTOR
gen ind3digit = floor(industry / 1000) if inlist(year, 2014, 2016)
gen ind2digit = floor(industry / 10000) if inlist(year, 2014, 2016)
gen ind1digit = floor(industry / 100000) if inlist(year, 2014, 2016)

forvalues i = 1/3 {
	rename ind`i'digit naics2017

	#delimit ;
	merge m:1 naics2017 using `naics',
		keepusing(cvsector) keep(1 3 4) update nogen;
	#delimit cr
	rename naics2017 ind`i'digit
}

label variable cvsector "Sector"
label define cvsector_lbl 0 "C" 1 "S"
label values cvsector cvsector_lbl

// HAND-TO-MOUTH VARIABLES

* Unable to pay all bills in full this month
* 2016-2018
gen paybills_h2m = .
replace paybills_h2m = 1 if paybills == 0
replace paybills_h2m = 0 if paybills == 1
label variable paybills_h2m "Unable to pay all bills in full this month"
	
* Unable to pay all bills in full this month if there is $400 emergency
* 2016-2018
gen paybills400_h2m = .
replace paybills400_h2m = 1 if (paybills == 0) | (paybills400 == 0)
replace paybills400_h2m = 0 if (paybills400 == 1)
label variable paybills400_h2m "Unable to pay bills this month if there is $400 emerg"

/* In past 12 months, how frequently have you paid only the min payment on
one or more credit cards? (0=never) (1=once) (2=some of the time)
(3=most or all of the time) */
* 2015-2017
gen ccmin_h2m = .
replace	ccmin_h2m = 1 if (ccmin == 3) & inrange(year, 2015, 2017)
replace ccmin_h2m = 0 if inrange(ccmin, 0, 2) & inrange(year, 2015, 2017)
label variable ccmin_h2m "Paid only min payment on one or more credit cards"

/* In past 12 months, how frequently have you carried an unpaid balance on one
or more of your credit cards? (0=never) (1=once) (2=some of the time)
(3=most or all of the time) */
* 2017-2018
gen ccunpaid_h2m = .
replace ccunpaid_h2m = 1 if (ccunpaid == 3) & inrange(year, 2017, 2018)
replace ccunpaid_h2m = 0 if inrange(ccunpaid, 0, 2) & inrange(year, 2017, 2018)
label variable ccunpaid_h2m "Carred unpaid balance on one or more credit cards"

* Rarely or never have money left over at the end of the month
* 2017
gen havemoney_h2m = .
replace havemoney_h2m = 1 if inrange(havemoney, 4, 5)
replace havemoney_h2m = 0 if inrange(havemoney, 1, 3)
label variable havemoney_h2m "Rarely or never have money left over at end of month"

* Set aside 3 months of emergency funds ("rainy day funds");
* 2013-2018
gen rainyday_h2m = .
replace rainyday_h2m = 1 if rainyday==0
replace rainyday_h2m = 0 if rainyday==1
label variable rainyday_h2m "Do not have 3 months of rainy day funds set aside"
	
* Could you cover expenses for 3 months by borrowing, using savings, etc...
* 2014-2018
gen coverexpenses_h2m = .
replace coverexpenses_h2m = 1 if coverexpenses == 0
replace coverexpenses_h2m = 0 if coverexpenses == 1
label variable coverexpenses_h2m "Could not cover expenses for 3 months"

* Could you cover a $400 emergency expense right now?
* 2014-2018
gen emerg_h2m = (emerg_wouldnt == 1) if !missing(emerg_wouldnt)
replace emerg_h2m = . if emerg_refused == 1
label variable emerg_h2m "Could not cover a $400 emerg expense right now"

/* In the past month, would you say that your (and your spouse's/and your
partner's income) was...  */
* 2013-2018
gen spendinc_h2m = .
replace spendinc_h2m = 1 if inlist(spendinc, 2, 3) & (year < 2018)
replace	spendinc_h2m = 0 if spendinc == 1 & (year < 2018)
replace spendinc_h2m = 1 if inlist(spendinc, 1, 2) & (year == 2018)
replace	spendinc_h2m = 0 if spendinc == 3 & (year == 2018)
label variable spendinc_h2m "Income was less or equal to than spending"

`#TARGET' save "build/output/shed_cleaned.dta", replace
