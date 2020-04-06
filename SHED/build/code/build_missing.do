// NOTE: FIRST RUN "do macros.do" IN THE MAIN DIRECTORY

/* Dataset: SHED */
/* This do-file codes missing values. */

clear
use "$SHEDbuildtemp/SHED_temp.dta"

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

save "$SHEDbuildtemp/SHED_temp2.dta", replace
