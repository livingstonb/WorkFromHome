/* --- MAKEFILE INSTRUCTIONS ---
*/

/* Dataset: SIPP */
/* This script aggregates to the annual frequency by summing earnings over
the year and using assets reported in the last month. */
`#PREREQ' use "build/temp/sipp_monthly2.dta", clear

// EARNINGS
bysort personid swave: egen earnings = total(grossearn)
label variable earnings "earnings"

by personid swave: egen wfh = max(workfromhome)
by personid swave: egen mwfh = max(wfh_mainocc)
drop workfromhome wfh_mainocc

replace wfh = 100 * wfh
replace mwfh = 100 * mwfh
rename wfh workfromhome
rename mwfh mworkfromhome
label variable workfromhome " % Who worked from home at least one day of the week"
label variable mworkfromhome " % Who worked from home at least one day of the week in main occ"

bysort personid swave: gen nmonths = _N
keep if (monthcode == 12) & (nmonths == 12)
drop nmonths

// WEALTH VARIABLES
* Liquid assets
egen pdeposits = rowtotal(val_sav val_ichk val_chk val_mm)
label variable pdeposits "deposits"

egen pbonds = rowtotal(val_govs val_mcbd)
label variable pbonds "government and corporate bonds"

egen pliqequity = rowtotal(val_st val_mf)
label variable pliqequity "stocks and mutual funds"

egen liquid = rowtotal(pdeposits pbonds pliqequity)
label variable liquid "liquid assets"

* Liquid liabilities
gen ccdebt = liab_ccdebt
label variable ccdebt "credit card debt"

* Illiquid
gen phomeequity = val_homeequity
label variable phomeequity "home equity"

egen pretirement = rowtotal(val_ira_keoh val_401k val_ann val_trusts)
label variable pretirement "retirement accounts"

egen netilliquid = rowtotal(phomeequity pretirement val_cd val_life)
label variable netilliquid "net illiquid assets"

// OTHER VARIABLES
gen netliquid = liquid - ccdebt
label variable netliquid "net liquid assets"

gen netliq_earnings_ratio = netliquid / earnings if (earnings > 1000)
label variable netliq_earnings_ratio "net liquid assets to earnings ratio for earnings > 1000"

tempvar earnwk
gen `earnwk' = earnings / 52

gen nla_lt_biweeklyearn = (netliquid < (2 * `earnwk'))
label variable nla_lt_biweeklyearn "Share with net liquid assets < 2 weeks earnings"

gen nla_lt_monthlyearn = (netliquid < (4 * `earnwk'))
label variable nla_lt_monthlyearn "Share with net liquid assets < 4 weeks earnings"

gen nla_lt_annearn = (netliquid < earnings)
label variable nla_lt_annearn "Share with net liquid assets < annual earnings"

gen whtm_biweeklyearn = (netliquid < (2 * `earnwk')) * (netilliquid >= 5000)
label variable whtm_biweeklyearn "Share WHtM (NLIQ < 2 wks earnings and NILLIQ >= $5000)"

gen whtm_monthlyearn = (netliquid < (4 * `earnwk')) * (netilliquid >= 5000)
label variable whtm_monthlyearn "Share WHtM (NLIQ < 4 wks earnings and NILLIQ >= $5000)"

gen whtm_annearn = (netliquid < earnings) * (netilliquid >= 5000)
label variable whtm_monthlyearn "Share WHtM (NLIQ < annual earnings and NILLIQ >= $5000)"

gen phtm_biweeklyearn = (nla_lt_biweeklyearn == 1) & (whtm_biweeklyearn == 0)
replace phtm_biweeklyearn = . if missing(nla_lt_biweeklyearn, whtm_biweeklyearn)

gen phtm_monthlyearn = (nla_lt_monthlyearn == 1) & (whtm_monthlyearn == 0)
replace phtm_monthlyearn = . if missing(nla_lt_monthlyearn, whtm_monthlyearn)

gen phtm_annearn = (nla_lt_annearn == 1) & (whtm_annearn == 0)
replace phtm_annearn = . if missing(nla_lt_annearn, whtm_annearn)

drop `earnwk'

`#TARGET' save "build/output/sipp_cleaned.dta", replace