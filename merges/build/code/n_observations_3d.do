/*
Grabs the number of observations for each occupation for ACS, ATUS,
and SIPP.
*/

clear

use "../ACS/stats/output/ACSwfh.dta", clear
append using "../ATUS/stats/output/ATUSwfh.dta"
append using "../SIPP/stats/output/SIPP3d_person.dta"
keep occ3d2010 nworkers_unw sector source

rename nworkers_unw n_
reshape wide n_, i(occ3d2010 sector) j(source) string

foreach var of varlist n_* {
	rename `var' `var'_sec
}
decode sector, gen(jd)
drop sector
reshape wide n_*, i(occ3d2010) j(jd) string

save "build/output/n_observations.dta", replace
