// NOTE: FIRST RUN "do macros.do" IN THE MAIN DIRECTORY

/* Dataset: SHED */
/* This is the main build script for SHED. */

clear

* Append years
gen year = .
forvalues yr = 2013/2018 {
	append using "build/input/SHED`yr'.dta"
	replace year = `yr' if missing(year)
}

rename weight3b wgt
replace wgt = weight3 if year == 2014
replace wgt = weight if year == 2013
replace wgt = weight2b if year == 2018
drop weight*

// RENAME VARIABLES;
* Make sure to add any new variables to build_missing.do to clean missing values!
rename B1_a havemoney
replace havemoney = . if (year == 2013)
rename M4 mortpmt
rename FM10_f savaut
rename C4A ccunpaid
rename C4B ccmin
rename SL6 behindstudpmts
rename K20 retsavings
rename DC4 fincomfort
rename K5A borrowret
rename I40 inccat
rename I12 billstruggle
rename I20 spendinc
replace spendinc = I1 if inrange(year, 2013, 2016)
rename ED0 educ
rename SL1 studdebt
rename EF1 rainyday
replace rainyday = E1B if inlist(year, 2013, 2014)
rename EF2 coverexpenses
replace coverexpenses = E1A if inlist(year, 2013, 2014)

* $400 emergency expense
rename EF3_a emerg_ccfull
rename EF3_b emerg_cctime
rename EF3_c emerg_cash
rename EF3_d emerg_loan
rename EF3_e emerg_friend
rename EF3_f emerg_paydayetc
rename EF3_g emerg_sell
rename EF3_h emerg_wouldnt
rename EF3_i emerg_other
rename EF3_Refused emerg_refused
replace emerg_ccfull = E3A_a if year == 2014
replace emerg_cctime = E3A_b if year == 2014
replace emerg_cash = E3A_c if year == 2014
replace emerg_loan = E3A_d if year == 2014
replace	emerg_friend = E3A_e if year == 2014
replace emerg_paydayetc	= E3A_f if year == 2014
replace emerg_sell = E3A_g if year == 2014
replace emerg_wouldnt = E3A_h if year == 2014
replace	emerg_other = E3A_i if year == 2014
replace	emerg_refused = E3A_Refused if year == 2014
replace emerg_ccfull = E3B_a if year == 2013
replace emerg_cctime = E3B_b if year == 2013
replace emerg_cash = E3B_c if year == 2013
replace emerg_loan = E3B_d if year == 2013
replace	emerg_friend = E3B_e if year == 2013
replace emerg_paydayetc	= E3B_f if year == 2013
replace emerg_sell = E3B_g if year == 2013
replace emerg_wouldnt = E3B_h if year == 2013
replace	emerg_other = E3B_i if year == 2013
replace	emerg_refused = E3B_Refused if year == 2013
drop E3A_* E3B_*

* able to pay all bills this month
rename EF5A paybills
* able to pay all bills even with a $400 emergency expense
rename EF5B paybills400

* delinquent on bills
rename EF6A_a delinq_rentmort
rename EF6A_b delinq_cc
rename EF6A_c delinq_util
rename EF6A_d delinq_phonecable
rename EF6A_e delinq_car
rename EF6A_f delinq_studloan
rename EF6A_g delinq_other
rename EF6B_a skip_rentmort
rename EF6B_b skip_cc
rename EF6B_c skip_util
rename EF6B_d skip_phonecable
rename EF6B_e skip_car
rename EF6B_f skip_studloan
rename EF6B_g skip_other

* couldn’t afford to make a necessary expenditure
rename E1_a notafford_med
rename E1_b notafford_doc
rename E1_c notafford_mentcare
rename E1_d notafford_dental
rename E1_e notafford_specialist
rename E1_f notafford_followup

* demographics and other variables;
rename CH2 educmother
replace educmother = ED15 if year == 2014
rename CH3 educfather
replace educfather = ED16 if year == 2014
rename FL1 finlit1
rename FL2 finlit2
rename FL3 finlit3
rename FL4 finlit4
rename FL5 finlit5
rename xhispan hispanic
rename xspanish spanish
rename ppage age
replace age = PPAGE if year == 2013
rename ppagecat agecat
replace agecat = PPAGECAT if year == 2013
rename ppeduc educ2
rename ppeducat educ2cat
rename ppethm race
replace race = PPETHM if year == 2013
rename ppgender gender
replace gender = PPGENDER if year == 2013
rename pphhhead hhhead
replace hhhead = PPHHHEAD if year == 2013
rename pphhsize hhsize
replace hhsize = PPHHSIZE if year == 2013
rename ppincimp hhincome
replace hhincome = PPINCIMP if year == 2013
rename ppmarit marital
replace marital = PPMARIT if year == 2013
rename ppreg4 region4
replace region4 = PPREG4 if year == 2013
rename ppreg9 region9
replace region9 = PPREG9 if year == 2013
rename ppstaten state
replace	state = PPSTATE if year == 2013
rename ppwork working
replace working = PPWORK if year == 2013
rename ppcm0160 occupation
rename ind2 industry
replace industry = IND2 if year == 2016
rename pph10001 physhealth
rename ppfs0596 savings

* generate variables
gen retired = (working == 5) if !missing(working)

* Drop unneeded variables
foreach var of varlist * {
	if inrange(substr("`var'", 1, 1), "A", "Z") local todrop `todrop' `var'
}
if "`todrop'" != "" drop `todrop'

#delimit ;
local codevars havemoney mortpmt savaut ccmin behindstudpmts
	retsavings borrowret inccat billstruggle spendinc 
	retired educ studdebt rainyday coverexpenses paybills paybills400 
	delinq_rentmort delinq_cc delinq_util
	delinq_phonecable delinq_car delinq_studloan delinq_other skip_rentmort 
	skip_cc skip_util skip_phonecable skip_car skip_studloan skip_other
	notafford_med notafford_doc notafford_mentcare notafford_dental 
	notafford_specialist notafford_followup ccunpaid
	educmother educfather hispanic spanish age agecat
	educ2 educ2cat race gender hhhead hhsize hhincome marital region4 region9
	state working occupation industry physhealth savings fincomfort finlit1 finlit2
	finlit3 finlit4 finlit5;
#delimit cr

foreach codevar of local codevars {
	replace `codevar' = . if inlist(`codevar', -9, -2, -1)
}

compress
save "build/temp/shed_temp.dta", replace