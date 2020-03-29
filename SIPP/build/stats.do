
use "$SIPPtemp/sipp_temp.dta", clear

// AGGREGATION
bysort personid: egen earnings = total(grossearn)
by personid: egen wfh = max(workfromhome)
drop workfromhome
rename wfh workfromhome
label variable "Worked from home at least one day of the week"

keep if (monthcode == 12)

// AGGREGATED ASSET VARIABLES
egen pdeposits = rowtotal(val_sav val_ichk val_chk val_mm)
egen pbonds = rowtotal(val_govs val_mcbd)
egen pliqequity = rowtotal(val_st val_mf)

egen liquid = rowtotal(pdeposits + pliqequity)

gen ccdebt = liab_ccdebt

egen illiquid = 
