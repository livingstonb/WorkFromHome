use "$build/cleaned/acs_cleaned.dta", clear
label define bin_lbl 0 "No" 1 "Yes", replace
label define bin_pct_lbl 0 "No" 100 "Yes", replace

// GENERATE NEW VARIABLES
// * Log wage difference from occ median
// gen lwageprem = log(incwage / medwage)
//
// * Log wage difference from metro median
// gen metro_lwageprem = log(incwage/ area_medwage)

// * Log median rent at workplace metro area
// gen lmedianrent = log(work_rent50)

gen renter = (rentgrs > 0)

* Percentages
#delimit ;
foreach var of varlist
	selfemployed bs_or_higher
	workfromhome hashealthins workdifficulty
	married renter fulltime {;
	gen pct_`var' = `var' * 100;
};
#delimit cr

label variable pct_hashealthins "% w/health insurance"
label variable pct_selfemployed "% self-employed"
label variable pct_bs_or_higher "% w/bachelor's deg or higher"
label variable pct_married "% currently married"
label variable pct_workfromhome "% WFH"
label variable pct_renter "% who rent (housing)"
label variable pct_fulltime "% full time workers"

* WFH averages by year
global wfh_vars pct_workfromhome
forvalues yr = 2000(3)2015 {
	local yr2 = `yr' + 2
	gen wfh_yrs`yr'_`yr2' = pct_workfromhome if inrange(year, `yr', `yr2')
	label variable wfh_yrs`yr'_`yr2' "% WFH, `yr'-`yr2'"
	label values wfh_yrs`yr'_`yr2' bin_pct_lbl
	global wfh_vars $wfh_vars wfh_yrs`yr'_`yr2'
}

gen wfh_incwage = incwage if (workfromhome == 1)
label variable wfh_incwage "Wage income, WFH only"

* Year dummies
global yearcounts
#delimit ;
forvalues yr = 2000/2018 {;
	gen dy`yr' = (year == `yr');
	label variable dy`yr' "`yr'";
	label values dy`yr' bin_lbl;
	
	global yearcounts $yearcounts dy`yr';
};
#delimit cr

gen counts = 1
label variable counts "n, unweighted"

gen nworkers = 1
label variable nworkers "Total # workers"

compress
