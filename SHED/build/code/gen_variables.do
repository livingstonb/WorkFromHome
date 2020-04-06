// NOTE: FIRST RUN "do macros.do" IN THE MAIN DIRECTORY

/* Dataset: SHED */
/* This do-file generates new variables for the SHED dataset. */

clear
use "$SHEDbuildtemp/SHED_temp2.dta"

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

/* In past 12 months, how frequently have you carried an unpaid balance on one
or more of your credit cards? (0=never) (1=once) (2=some of the time)
(3=most or all of the time) */
* 2017-2018
gen ccunpaid_h2m = .
replace ccunpaid_h2m = 1 if (ccunpaid == 3) & inrange(year, 2017, 2018)
replace ccunpaid_h2m = 0 if inrange(ccunpaid, 0, 2) & inrange(year, 2017, 2018)

* Rarely or never have money left over at the end of the month
* 2017
gen havemoney_h2m = .
replace havemoney_h2m = 1 if inrange(havemoney, 4, 5)
replace havemoney_h2m = 0 if inrange(havemoney, 1, 3)

* Set aside 3 months of emergency funds ("rainy day funds");
* 2013-2018
gen rainyday_h2m = .
replace rainyday_h2m = 1 if rainyday==0
replace rainyday_h2m = 0 if rainyday==1
	
* Could you cover expenses for 3 months by borrowing, using savings, etc...
* 2014-2018
gen coverexpenses_h2m = .
replace coverexpenses_h2m = 1 if coverexpenses == 0
replace coverexpenses_h2m = 0 if coverexpenses == 1

* Could you cover a $400 emergency expense right now?
* 2014-2018
gen emerg_h2m = (emerg_wouldnt == 1) if !missing(emerg_wouldnt)
replace emerg_h2m = . if emerg_refused == 1

/* In the past month, would you say that your (and your spouse's/and your
partner's income) was...  */
* 2013-2018
gen spendinc_h2m = .
replace spendinc_h2m = 1 if inlist(spendinc, 2, 3) & (year < 2018)
replace	spendinc_h2m = 0 if spendinc == 1 & (year < 2018)
replace spendinc_h2m = 1 if inlist(spendinc, 1, 2) & (year == 2018)
replace	spendinc_h2m = 0 if spendinc == 3 & (year == 2018)

save "$SHEDout/SHED.dta", replace
