clear

if "$build" == "" {
	global build "/media/hdd/GitHub/WorkFromHome/build"
}
local raw "$build/raw"

* Read raw dataset
global raw_dat_path "`raw'/acs_raw.dat"
do "`raw'/acs_raw.do"

#delimit ;
local keepvars
	year sex famsize nchild age marst
	hispan school educ educd degfield empstat
	empstatd labforce occ2010 ind classwkr classwkrd
	wkswork2 uhrswork workedyr inctot
	incwage incbus00 incss incwelfr incinvst incretir
	incsupp incother poverty vetstat hcovany
	pwstate2 tranwork trantime cpi99 perwt
	racamind racasian racblk racpacis racwht racother
	diffrem diffphys diffmob diffcare diffsens diffeye
	diffhear;
keep `keepvars';
#delimit cr

keep if (age >= 16) & !missing(age)
keep if (incwage > 0) & !missing(incwage)

* Rename variables
rename educ educ_orig
rename educd educd_orig
rename racamind amindian
rename racasian asian
rename racblk black
rename racpacis pacislander
rename racwht white
rename racother otherrace
rename school inschool
rename vetstat veteran
rename hcovany hashealthins

* Recode as missing
recode tranwork (0 = .)
recode inschool (0 9 = .)
recode educ_orig (0 = .)
recode educd_orig (0 1 999 = .)
recode classwkr (0 = .)
recode classwkrd (0 = .)
recode wkswork2 (0 = .)
recode uhrswork (0 = .)
recode veteran (0 9 = .)
recode poverty (0 = .)
recode degfield (0 = .)
recode occ2010 (9920 = .)

foreach var of varlist diff* {
	recode `var' (0 = .)
}

* Recode as missing, income variables
recode inctot (9999999 = .)
recode incwage (9999998 9999999 = .)
recode incbus00 (999999 = .)
recode incss (999999 = .)
recode incwelfr (99999 = .)
recode incinvst (999999 = .)
recode incretir (999999 = .)
recode incsupp (99999 = .)
recode incother (99999 = .)

* Generate unique identifier
gen id = _n

capture mkdir "$build/temp"
save $build/temp/acs_temp.dta, replace