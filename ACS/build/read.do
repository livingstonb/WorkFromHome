clear

if "$build" == "" {
	global build "/media/hdd/GitHub/WorkFromHome/build"
}
local raw "$build/raw"

* Read raw dataset
global raw_dat_path "`raw'/acs_raw.dat"
do "`raw'/acs_raw.do"

#delimit ;
if "$occ_ind_breakdown" == "1" {;
keep if (year >= 2017)
keep
	year age empstatd occ ind empstat
	empstatd classwkr classwkrd wkswork2 uhrswork
	inctot incwage farm cpi99 perwt;
};
else {;
rename occ occn;
keep
	year sex famsize nchild age marst occn
	hispan school educ educd degfield empstat pernum
	empstatd occ2010 ind classwkr classwkrd
	wkswork2 uhrswork inctot met2013 farm
	incwage incbus00 incss incwelfr incinvst incretir
	incsupp incother poverty vetstat hcovany
	pwstate2 tranwork trantime cpi99 perwt rentgrs
	racamind racasian racblk racpacis racwht racother
	diffrem diffphys diffmob diffcare diffsens diffeye
	diffhear pwmet13 pwtype;
};
#delimit cr

if "$occ_ind_breakdown" == "1" {
	* Rename variables
	rename occ occupation
	rename ind industry

	* Recode as missing
	recode classwkr (0 = .)
	recode classwkrd (0 = .)
	recode wkswork2 (0 = .)
	recode uhrswork (0 = .)
	recode occupation (9920 0 = .)
	recode incwage (9999998 9999999 = .)
	recode industry (9920 0 = .)
}
else {
	* Rename variables
	rename ind industry
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
	rename pwtype metropolitan
	rename pwmet13 workplace_metro
	rename met2013 residence_metro

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
	recode occn (9920 0 = .)
	recode metropolitan (0 9 = .)
	recode workplace_metro (0 = .)
	recode residence_metro (0 = .)
	recode industry (9920 0 = .)

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
}

* Drop observations
keep if (age >= 15) & !missing(age)
keep if (incwage > 0) & !missing(incwage)

compress
capture mkdir "$build/temp"

if "$occ_ind_breakdown" == "1" {
	save "$build/temp/occ_ind_temp.dta", replace
}
else {
	save "$build/temp/acs_temp.dta", replace
}
