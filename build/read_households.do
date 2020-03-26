clear

if "$build" == "" {
	global build "/media/hdd/GitHub/WorkFromHome/build"
}
local raw "$build/raw"

* Read raw dataset
global raw_dat_path "`raw'/acs_raw.dat"
do "`raw'/acs_raw.do"

#delimit ;
keep year serial famunit pernum hhwt rentgrs met2013
	cpi99;
#delimit cr

* Rename variables
rename met2013 residence_metro

* Adjust to 2018 dollars
quietly sum cpi99 if (year == 2018)
local cpi1999_2018 = `r(max)'
gen cpi2018 = cpi99 / `cpi1999_2018'

replace rentgrs = rentgrs * cpi2018

* Compute rent percentiles
keep if (pernum == 1)
drop if (residence_metro == 0) | missing(residence_metro)
drop pernum serial famunit cpi99
drop if (rentgrs == 0) | missing(rentgrs)

#delimit ;
collapse (p25) rent25=rentgrs (p50) rent50=rentgrs
	(p75) rent75=rentgrs [iw=hhwt], by(year residence_metro);
#delimit cr

save "$build/cleaned/acs_rents.dta", replace
