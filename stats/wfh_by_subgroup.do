clear

use "$build/cleaned/acs_cleaned.dta", clear
label define bin_lbl 0 "No" 1 "Yes", replace

// GENERATE NEW VARIABLES
* Percentages
#delimit ;
foreach var of varlist
	selfemployed bs_or_higher
	workfromhome hashealthins workdifficulty
	married haschildren {;
	gen pct_`var' = `var' * 100;
};
#delimit cr

* WFH averages by year
global wfh_vars pct_workfromhome
global wfh_lbls `" "% WFH" "'
forvalues yr = 2001(3)2016 {
	local yr2 = `yr' + 2
	gen wfh_yrs`yr'_`yr2' = pct_workfromhome if inrange(year, `yr', `yr2')
	label variable wfh_yrs`yr'_`yr2' "WFH, `yr'-`yr2'"
	label values wfh_yrs`yr'_`yr2' bin_lbl

	global wfh_vars $wfh_vars wfh_yrs`yr'_`yr2'
	global wfh_lbls `" $wfh_lbls "%WFH, `yr'-`yr2'" "'
}

gen wfh_incwage = incwage if (workfromhome == 1)
label variable wfh_incwage "Wage income, if worker is WFH"

* Year dummies
local yearcounts
#delimit ;
forvalues yr = 2000/2018 {;
	gen d`yr' = (year == `yr');
	label variable d`yr' "Year `yr' dummy";
	label values d`yr' bin_lbl;
	
	local yearcounts `yearcounts' (rawsum) nobs_unweighted`yr'=d`yr'
		(sum) nobs_weighted`yr'=d`yr';
};
#delimit cr

gen ones = 1
label variable ones "Counts"

// OCCUPATION COUNTS, BY YEAR
global bylist occupation
global vlist `yearcounts' (rawsum) n_unweighted=ones (sum) n_weighted=ones
// global vlbls "Occupation" "n (unweighted)" "n (weighted)"
global xlxpath "$statsout/occupation_counts.xlsx"
do "$stats/collapse_table.do"

// BY YEAR
* Percent work from home by year
global bylist year
#delimit ;
global vlist
	(count) nrespondents=workfromhome
	(sum) wfh_workers=workfromhome (mean) pct_workfromhome
	(median) incwage (median) wfh_incwage;
#delimit cr
global xlxpath "$statsout/wfh_by_year.xlsx"
do "$stats/collapse_table.do"

// BY SUBGROUP, COLUMNS ARE %WFH IN n-YEAR INTERVALS
* Percent work from home by occupation
global bylist occupation
global vlist $wfh_vars
global xlxpath "$statsout/wfh_by_occupation.xlsx"
do "$stats/collapse_table.do"

* Percent work from home by sex
global bylist sex
global vlist $wfh_vars
global vlbls `" "Sex" $wfh_lbls "'
global xlxpath "$statsout/wfh_by_sex.xlsx"
do "$stats/collapse_table.do"

* Percent work from home by race
global bylist race
global vlist $wfh_vars
global xlxpath "$statsout/wfh_by_race.xlsx"
do "$stats/collapse_table.do"

* Percent work from home by education
global bylist education
global vlist $wfh_vars
global xlxpath "$statsout/wfh_by_education.xlsx"
do "$stats/collapse_table.do"

* WFH by wage quintile
global bylist wage_quintile
global vlist $wfh_vars
global xlxpath "$statsout/wfh_by_wage_quintile.xlsx"
do "$stats/collapse_table.do"

* WFH by age group
global bylist agecat
global vlist $wfh_vars
global xlxpath "$statsout/wfh_by_age.xlsx"
do "$stats/collapse_table.do"

* Private vs. public sector workers
global bylist govworker
global vlist $wfh_vars
global xlxpath "$statsout/private_vs_public.xlsx"
do "$stats/collapse_table.do"

// BREAKDOWN OF WFH WORKERS
* WFH workers vs NWFH workers
global collapse_commands "keep if inrange(year, 2016, 2018)"
global bylist workfromhome
#delimit ;
global vlist
	pct_selfemployed pct_hashealthins pct_workdifficulty pct_married nchild
	pct_bs_or_higher meanwage=incwage (median) medwage=incwage;
#delimit cr
global xlxpath "$statsout/wfh_vs_not_wfh.xlsx"
do "$stats/collapse_table.do"
