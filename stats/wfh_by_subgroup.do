clear

use "$build/cleaned/acs_cleaned.dta", clear

// DROP VARIABLES
drop if (year < 2010)

// GENERATE NEW VARIABLES
* WFH individuals that are not self-employed
gen wfh_not_selfemp = workfromhome if (selfemployed == 0)

gen wfh_2010_2012 = workfromhome if inrange(year, 2010, 2012)
gen wfh_2013_2015 = workfromhome if inrange(year, 2013, 2015)
gen wfh_2016_2018 = workfromhome if inrange(year, 2016, 2018)
gen wfh_not_selfemp_2016_2018 = wfh_not_selfemp if inrange(year, 2016, 2018)

gen wfh_incwage = incwage if (workfromhome == 1)

// COMPUTE STATISTICS
* Percent work from home by year
global bylist year
global vlist workfromhome (median) incwage (median) wfh_incwage
global xlxpath "$statsout/wfh_by_year.xlsx"
do "$stats/collapse_table.do"

* Percent work from home by occupation
global bylist occupation
global vlist wfh_2010_2012 wfh_2013_2015 wfh_2016_2018 
global xlxpath "$statsout/wfh_by_occupation.xlsx"
do "$stats/collapse_table.do"

* Percent work from home by sex
global bylist sex
global vlist wfh_2010_2012 wfh_2013_2015 wfh_2016_2018 
global xlxpath "$statsout/wfh_by_sex.xlsx"
do "$stats/collapse_table.do"

* Percent work from home by race
global bylist race
global vlist wfh_2010_2012 wfh_2013_2015 wfh_2016_2018 
global xlxpath "$statsout/wfh_by_race.xlsx"
do "$stats/collapse_table.do"

* Percent work from home by education
global bylist education
global vlist wfh_2010_2012 wfh_2013_2015 wfh_2016_2018 
global xlxpath "$statsout/wfh_by_education.xlsx"
do "$stats/collapse_table.do"

* WFH by wage quintile
global bylist wage_quintile
global vlist wfh_2010_2012 wfh_2013_2015 wfh_2016_2018
global xlxpath "$statsout/wfh_by_wage_quintile.xlsx"
do "$stats/collapse_table.do"

* WFH by age group
global bylast agecat
global vlist wfh_2010_2012 wfh_2013_2015 wfh_2016_2018
global xlxpath "$statsout/wfh_by_age.xlsx"
do "$stats/collapse_table.do"

* WFH workers vs NWFH workers
global bylist workfromhome
global vlist selfemployed hashealthins workdifficulty bs_or_higher meanwage=incwage (median) medwage=incwage 
global xlxpath "$statsout/wfh_vs_not_wfh.xlsx"
do "$stats/collapse_table.do"
