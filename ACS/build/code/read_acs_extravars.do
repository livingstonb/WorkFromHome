#delimit ;
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
#delimit cr

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
rename pwtype metropolitan
rename pwmet13 workplace_metro
rename met2013 residence_metro

* Recode as missing
recode inschool (0 9 = .)
recode educ_orig (0 = .)
recode educd_orig (0 1 999 = .)
recode veteran (0 9 = .)
recode poverty (0 = .)
recode degfield (0 = .)
recode occ2010 (9920 = .)
recode metropolitan (0 9 = .)
recode workplace_metro (0 = .)
recode residence_metro (0 = .)

foreach var of varlist diff* {
	recode `var' (0 = .)
}

* Recode as missing, income variables
recode inctot (9999999 = .)
recode incbus00 (999999 = .)
recode incss (999999 = .)
recode incwelfr (99999 = .)
recode incinvst (999999 = .)
recode incretir (999999 = .)
recode incsupp (99999 = .)
recode incother (99999 = .)