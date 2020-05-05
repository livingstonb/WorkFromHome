/* --- HEADER ---
Grabs the number of observations for each occupation for ACS, ATUS,
and SIPP.
*/

clear

`#PREREQ' use "../ACS/stats/output/ACSwfh.dta", clear
`#PREREQ' append using "../ATUS/stats/output/ATUSwfh.dta"
`#PREREQ' append using "../SIPP/stats/output/SIPPwfh.dta"
keep occ3d2010 nworkers_unw sector source

rename nworkers_unw n_
reshape wide n_, i(occ3d2010 sector) j(source) string

foreach var of varlist n_* {
	rename `var' `var'_sec
}
decode sector, gen(jd)
drop sector
reshape wide n_*, i(occ3d2010) j(jd) string

`#TARGET' save "build/output/n_observations.dta", replace
