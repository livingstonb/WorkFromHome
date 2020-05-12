/*
Reads the raw data from the .dat file and
performs some minor cleaning tasks. Assumes the cwd
is ACS.
*/

args extra_variables

* Read raw dataset
use "build/input/acs_raw.dta", clear

rename occ occn

if "`extra_variables'" == "1" {
	* Not used
	do "build/code/read_acs_extravars.do"
}
else {
	#delimit ;
	keep
		year age occn empstat empstatd ind classwkr classwkrd
		wkswork2 uhrswork inctot incwage tranwork trantime
		cpi99 perwt rentgrs;
	#delimit cr
}

* Rename variables
rename ind industry

* Recode as missing
recode tranwork (0 = .)
recode classwkr (0 = .)
recode classwkrd (0 = .)
recode wkswork2 (0 = .)
recode uhrswork (0 = .)
recode occn (9920 0 = .)
recode industry (9920 0 = .)

* Recode as missing, income variables
recode incwage (9999998 9999999 = .)

* Drop observations
keep if (age >= 15) & !missing(age)
keep if (incwage > 0) & !missing(incwage)

compress
save "build/temp/acs_temp.dta", replace
