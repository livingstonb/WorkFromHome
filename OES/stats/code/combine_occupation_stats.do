/*
#PREREQ "stats/output/summary_by_occupation_2000.dta"
#PREREQ "stats/output/summary_by_occupation_2001.dta"
#PREREQ "stats/output/summary_by_occupation_2002.dta"
#PREREQ "stats/output/summary_by_occupation_2003.dta"
#PREREQ "stats/output/summary_by_occupation_2004.dta"
#PREREQ "stats/output/summary_by_occupation_2005.dta"
#PREREQ "stats/output/summary_by_occupation_2006.dta"
#PREREQ "stats/output/summary_by_occupation_2007.dta"
#PREREQ "stats/output/summary_by_occupation_2008.dta"
#PREREQ "stats/output/summary_by_occupation_2009.dta"
#PREREQ "stats/output/summary_by_occupation_2009.dta"
#PREREQ "stats/output/summary_by_occupation_2010.dta"
#PREREQ "stats/output/summary_by_occupation_2011.dta"
#PREREQ "stats/output/summary_by_occupation_2012.dta"
#PREREQ "stats/output/summary_by_occupation_2013.dta"
#PREREQ "stats/output/summary_by_occupation_2014.dta"
#PREREQ "stats/output/summary_by_occupation_2015.dta"
#PREREQ "stats/output/summary_by_occupation_2016.dta"
#PREREQ "stats/output/summary_by_occupation_2017.dta"
#PREREQ "stats/output/summary_by_occupation_2018.dta"
#PREREQ "stats/output/summary_by_occupation_2019.dta"
*/

clear

gen year = .
forvalues yr = 2000/2019 {
	append using "stats/output/summary_by_occupation_`yr'.dta"
	replace year = `yr' if missing(year)
}

* Append blanks
expand 5 if soc3d2010 == 453 & year == 2004, gen(iexpand)
gen cumexpand = sum(iexpand)
replace year = 1999 + cumexpand if iexpand

foreach var of varlist meanwage employment {
	replace `var' = . if iexpand
}
drop cumexpand iexpand

expand 3 if soc3d2010 == 453 & year == 2004, gen(iexpand)
gen cumexpand = sum(iexpand)
replace year = 2017 + cumexpand if iexpand

foreach var of varlist meanwage employment {
	replace `var' = . if iexpand
}
drop cumexpand iexpand

sort soc3d2010 year
order soc3d2010 year

`#TARGET' save "stats/output/occupation_level_employment.dta", replace
