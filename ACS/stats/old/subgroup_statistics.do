// NOTE: THIS SCRIPT IS OUTDATED AND LIKELY WILL NOT RUN

use "$ACScleaned/acs_cleaned.dta", clear
label define bin_lbl 0 "No" 1 "Yes", replace
label define bin_pct_lbl 0 "No" 100 "Yes", replace

// GENERATE NEW VARIABLES
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

gen wfh_yrs2018 = pct_workfromhome if (year == 2018)
label variable wfh_yrs2018 "%WFH, 2018 only"
label values wfh_yrs2018 bin_pct_lbl

global wfh_vars $wfh_vars wfh_yrs2018

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


// OCCUPATION COUNTS
* Contents sheet
local sheet1 "Weighted estimates of total # workers in occupation"
local sheet2 "Number of actual survey respondents in occupation"
local xlxname "$ACSstatsout/occupation_counts.xlsx"

putexcel set "`xlxname'", replace sheet("Contents")
putexcel A1 = "SHEET" B1 = "DESCRIPTION"
putexcel A2 = "A" B2 = "`sheet1'"
putexcel A3 = "B" B3 = "`sheet2'"

* Weighted
collapse2mat (sum) $yearcounts [iw=perwt], by(occupation) keeplabels
matrix statsmat = r(stats)

mat2excel statsmat using "`xlxname'", sheet("A - weighted") title("`sheet1'")

* Unweighted
collapse2mat (sum) $yearcounts, by(occupation) keeplabels
matrix statsmat = r(stats)

mat2excel statsmat using "`xlxname'", sheet("B - unweighted") title("`sheet2'")


// WFH BY YEAR
gen temp1 = workfromhome
label variable temp1 "# WFH"

gen temp2 = incwage
label variable temp2 "Median wage, all workers"

gen temp3 = incwage if (workfromhome == 1)
label variable temp3 "Median wage, WFH only"

#delimit ;
collapse2mat (sum) nworkers (sum) temp1
	(mean) pct_workfromhome (median) temp2
	(median) temp3
	[iw=perwt], by(year) keeplabels;
matrix statsmat = r(stats);

mat2excel statsmat using "$statsout/wfh_by_year.xlsx",
	replace title("% WFH by year");

#delimit cr
drop temp*

// WFH BY SEX
local xlxname "$ACSstatsout/wfh_by_sex.xlsx"

collapse2mat (mean) $wfh_vars [iw=perwt], by(sex) keeplabels
matrix statsmat = r(stats)

mat2excel statsmat using "`xlxname'", replace title("% WFH by sex")



* global bylist year
* #delimit ;
* global vlist
* 	(count) nrespondents=workfromhome
* 	(sum) wfh_workers=workfromhome (mean) pct_workfromhome
* 	(median) incwage (median) wfh_incwage;
* #delimit cr
* global xlxpath "$statsout/wfh_by_year.xlsx"
* do "$stats/collapse_table.do"

* // BY SUBGROUP, COLUMNS ARE %WFH IN n-YEAR INTERVALS
* * Percent work from home by occupation
* global bylist occupation
* global vlist $wfh_vars
* global xlxpath "$statsout/wfh_by_occupation.xlsx"
* do "$stats/collapse_table.do"

* * Percent work from home by sex
* global bylist sex
* global vlist $wfh_vars
* global vlbls `" "Sex" $wfh_lbls "'
* global xlxpath "$statsout/wfh_by_sex.xlsx"
* do "$stats/collapse_table.do"

* * Percent work from home by race
* global bylist race
* global vlist $wfh_vars
* global xlxpath "$statsout/wfh_by_race.xlsx"
* do "$stats/collapse_table.do"

* * Percent work from home by education
* global bylist education
* global vlist $wfh_vars
* global xlxpath "$statsout/wfh_by_education.xlsx"
* do "$stats/collapse_table.do"

* * WFH by wage quintile
* global bylist wage_quintile
* global vlist $wfh_vars
* global xlxpath "$statsout/wfh_by_wage_quintile.xlsx"
* do "$stats/collapse_table.do"

* * WFH by age group
* global bylist agecat
* global vlist $wfh_vars
* global xlxpath "$statsout/wfh_by_age.xlsx"
* do "$stats/collapse_table.do"

* * Private vs. public sector workers
* global bylist govworker
* global vlist $wfh_vars
* global xlxpath "$statsout/private_vs_public.xlsx"
* do "$stats/collapse_table.do"

// BREAKDOWN OF WFH WORKERS
* WFH workers vs NWFH workers
* global collapse_commands "keep if inrange(year, 2016, 2018)"
* global bylist workfromhome
* #delimit ;
* global vlist
* 	pct_selfemployed pct_hashealthins pct_workdifficulty pct_married nchild
* 	pct_bs_or_higher pct_renter pct_fulltime meanwage=incwage (median) medwage=incwage;
* #delimit cr
* global xlxpath "$statsout/wfh_vs_not_wfh.xlsx"
* do "$stats/collapse_table.do"
