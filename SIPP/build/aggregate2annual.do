
use "$SIPPtemp/sipp_monthly_with_su.dta", clear

// EARNINGS
bysort personid: egen earnings = total(grossearn)
label variable earnings "earnings"

by personid: egen wfh = max(workfromhome)
drop workfromhome

replace wfh = 100 * wfh
rename wfh workfromhome
label variable workfromhome " % Who worked from home at least one day of the week"

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

save "$SIPPout/sipp_cleaned.dta", replace
