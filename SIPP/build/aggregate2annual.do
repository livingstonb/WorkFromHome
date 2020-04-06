// NOTE: FIRST RUN "do macros.do" IN THE MAIN DIRECTORY

/* Dataset: SIPP */
/* This script aggregates to the annual frequency by summing earnings over
the year and using assets reported in the last month. */

/* Must first set the global macro: wave. */

use "$SIPPtemp/sipp_monthly_with_su_w${wave}.dta", clear

// EARNINGS
bysort personid: egen earnings = total(grossearn)
label variable earnings "earnings"

by personid: egen wfh = max(workfromhome)
by personid: egen mwfh = max(wfh_mainocc)
drop workfromhome wfh_mainocc

replace wfh = 100 * wfh
replace mwfh = 100 * mwfh
rename wfh workfromhome
rename mwfh mworkfromhome
label variable workfromhome " % Who worked from home at least one day of the week"
label variable mworkfromhome " % Who worked from home at least one day of the week in main occ"

keep if !missing(_sampleunit)
keep if (monthcode == 12)

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
gen phomeequity = hhhomeequity * aweights
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

save "$SIPPout/sipp_cleaned_w${wave}.dta", replace
