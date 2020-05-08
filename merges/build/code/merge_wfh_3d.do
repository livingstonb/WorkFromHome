/* --- HEADER ---
Combines datasets into one larger dataset which provided
statistics by occupation.
*/

clear

tempfile oestmp
`#PREREQ' use "../OES/stats/output/OESstats.dta", clear
rename meanwage oes_meanwage
rename nworkers_wt oes_employment
save `oestmp'

tempfile dntmp
`#PREREQ' use "../DingelNeiman/build/output/DN_3digit.dta", clear
gen source = "DingelNeiman"
drop employment
rename soc3d2010 occ3d2010
save `dntmp'

`#PREREQ' use "../ACS/stats/output/ACSwfh.dta", clear
`#PREREQ' append using "../ATUS/stats/output/ATUSwfh.dta"
`#PREREQ' append using "../SIPP/stats/output/SIPPwfh.dta"
append using `dntmp'

merge m:1 occ3d2010 sector using `oestmp', keepusing(oes_meanwage oes_employment)

drop blankobs

rename source srctmp
encode srctmp, gen(source)
drop srctmp

label variable oes_employment "Employment level in occ-sector pair from OES"
label variable oes_meanwage "Mean wage in occ-sector pair from OES"
label variable source "Dataset"
label variable pct_workfromhome "% WFH"
label variable nworkers_wt "Est of total workers in group"
label variable nworkers_unw "n, Actual num respondents"
label variable teleworkable "DN Teleworkable"

label variable meanwage "Mean wage"
label variable pct_canwfh "% can WFH"

drop _merge

* New variables
bysort sector source: egen empsec = total(oes_employment)
gen oes_occshare = oes_employment / empsec
drop empsec
label variable oes_occshare "Emp share of occupation within sector, OES"

gen essential = 1

order sector occ3d2010 oes* source pct_workfromhome
sort occ3d2010 sector source

compress
`#TARGET' save "build/output/wfh_merged.dta", replace
