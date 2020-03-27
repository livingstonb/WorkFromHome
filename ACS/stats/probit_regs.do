use "$build/cleaned/acs_cleaned.dta", clear
label define bin_lbl 0 "No" 1 "Yes", replace
label define bin_pct_lbl 0 "No" 100 "Yes", replace

// GENERATE NEW VARIABLES
* Log(wage / median wage of occupation)
gen lwageprem = log(incwage / medwage)

* Log wage for metro area
gen lmetrowage = log(area_medwage)

* Log median rent at workplace metro area
gen lmedianrent = log(work_rent50)

gen lwage = log(incwage)
gen lrent = log(rentgrs)

gen renter = (rentgrs > 0)
drop if (renter != 1)

gen period = year - 1999
gen agesq = age * age

drop if (selfemployed == 1) | (fulltime == 0)

#delimit ;
probit workfromhome
	i.occupation period lwageprem white sex age agesq bs_or_higher
	lmedianrent lmetrowage [iw=perwt];
	
probit workfromhome period lwage i.white i.sex age agesq i.bs_or_higher
	lrent c.period#c.lrent  lmetrowage [iw=perwt] if occupation == 2

#delimit cr


// Collapse by occ-year
use "$build/cleaned/acs_cleaned.dta", clear
drop if selfemployed == 1
gen renter = (rentgrs > 0)
keep if inrange(year, 2005, 2017)

gen ttime_condl = trantime if (workfromhome==1)
gen w_condl = wage if (workfromhome==1)
#delimit ;
collapse trantime ttime_condl bs_or_higher white incwage
	sex age govworker renter wage fulltime workfromhome
	married (median) median_wage=wage [iw=perwt], by(year occupation);
#delimit cr

gen period = year - 1999
gen agesq = age * age
gen lwage = log(median_wage)

reg workfromhome period age white sex married renter ttime_condl c.period#c.ttime_condl lwage, robust
