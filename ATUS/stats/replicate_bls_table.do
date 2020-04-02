* Load cleaned dataset
cd "$ATUSdir"
use "$ATUSdata/cleaned/ATUS_cleaned.dta", clear

gen nworkers = 1

gen pct_canwfh = 100 * canwfh
gen pct_doeswfh = 100 * doeswfh
gen pct_wfhtotal = 100

gen pct_wfhpaidyes = 100 * (paidwfh == 1) if !missing(paidwfh)
gen pct_wfhpaidno = 100 * (paidwfh == 2) if !missing(paidwfh)
gen pct_wfhpaidboth = 100 * (paidwfh == 3) if !missing(paidwfh)

* Recreate BLS tables
gen totw = 1
label variable totw "Age"
label define totw_lbl 1 "Total, 15 years and over"
label values totw totw_lbl

label define sex_lbl 1 "Men" 2 "Women"
label values sex sex_lbl

label variable agecat "Age"
label variable sex "Sex"
label variable race "Race"

label variable hispanic "Hispanic or Latino ethnicity"
label define hispanic_lbl 0 "non-Hispanic or Latino ethnicity", replace
label define hispanic_lbl 1 "Hispanic or Latino", add
label values hispanic hispanic_lbl

label define haschild_lbl 0 "Not a parent of a household child under 18 years", replace
label define haschild_lbl 1 "Parent of a household child under 18 years", add
label values haschild haschild_lbl

#delimit ;
local i = 0;
foreach var of varlist
	totw agecat sex race hispanic education haschild hasyoungchild
	occupation  industry gsector dprivatewkr dpublicwkr
	singjob_fulltime earnq flexhours
{;
	preserve;

	drop if missing(`var');
	collapse (sum) nworkers
		(sum) canwfh
		(mean) pct_canwfh
		(sum) doeswfh
		(mean) pct_doeswfh
		(firstnm) pct_wfhtotal
		(mean) pct_wfhpaidyes
		(mean) pct_wfhpaidno
		(mean) pct_wfhpaidboth
		[iw=normwt], by(`var');

	label variable nworkers "Total workers (thousands)";
	label variable canwfh "Total (thousands)";
	label variable pct_canwfh "Percent of total workers";
	label variable doeswfh "Total (thousands)";
	label variable pct_doeswfh "Percent of total workers";
	label variable pct_wfhtotal "Total";
	label variable pct_wfhpaidyes "Paid";
	label variable pct_wfhpaidno "Unpaid";
	label variable pct_wfhpaidboth "Both";
	
	local catlbl : variable label `var';
	gen category = "`catlbl'";
	
	decode `var', gen(subgroup);
	drop `var';
	order category subgroup;
	
	tempfile table`i';
	save `table`i'';

	restore;
	local ++i;
};
#delimit cr
local --i

use `table0', clear

forvalues j = 1/`i' {
	append using `table`j''
}



