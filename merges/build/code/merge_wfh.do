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
`#PREREQ' use "../DingelNeiman/build/output/DN_aggregated.dta", clear
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
label variable pct_workfromhome "% WFH in occ-sector pair"
label variable nworkers_wt "Est of total workers in group"
label variable nworkers_unw "n, Actual num respondents"

label variable mean_pdeposits "Mean deposits"
label variable mean_pbonds "Mean bonds"
label variable mean_pliqequity "Mean stocks and mutual funds"
label variable mean_ccdebt "Mean credit card debt"
label variable mean_netliquid "Mean net liquid assets"
label variable mean_netliq_earnings_ratio "Mean net liq assets to earn ratio if earn gt 1000"
label variable mean_liquid_nocash "Mean liquid assets"
label variable mean_liquid_wcash "Mean liquid assets, with assumed cash"
label variable mean_netilliquid "Mean net illiquid assets"

label variable nla_lt_biweeklyearn "Share with net liq assets < wkly earn * 2"
label variable nla_lt_monthlyearn "Share with net liq assets < wkly earn * 4"
label variable nla_lt_annearn "Share with net liq assets < annual earn"
label variable whtm_biweeklyearn "Share with net liq < wkly earn * 2 and net illiq gt 10000"
label variable whtm_monthlyearn "Share with net liq < wkly earn * 4 and net illiq gt 10000"

label variable median_pdeposits "Median deposits"
label variable median_pbonds "Median bonds"
label variable median_pliqequity "Median stocks and mutual funds"
label variable median_ccdebt "Median credit card debt"
label variable median_netliquid "Median net liquid assets"
label variable median_netliq_earnings_ratio "Median net liq assets to earn ratio if earn gt 1000"
label variable median_liquid_nocash "Median liquid assets, not net"
label variable median_liquid_wcash "Median liquid assets w/assumed cash, not net"
label variable median_netilliquid "Median net illiquid assets"

label variable meanwage "Mean wage, from given dataset"
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
