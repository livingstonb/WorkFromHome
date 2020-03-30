
use "$SIPPtemp/sipp_temp.dta", clear

// AGGREGATION
bysort personid: egen earnings = total(grossearn)
label variable earnings "earnings"

by personid: egen wfh = max(workfromhome)
drop workfromhome

replace wfh = 100 * wfh
rename wfh workfromhome
label variable workfromhome " % Who worked from home at least one day of the week"

keep if (monthcode == 12)

// AGGREGATED ASSET VARIABLES
egen pdeposits = rowtotal(val_sav val_ichk val_chk val_mm)
egen pbonds = rowtotal(val_govs val_mcbd)
egen pliqequity = rowtotal(val_st val_mf)

egen liquid = rowtotal(pdeposits pbonds pliqequity)
gen ccdebt = liab_ccdebt
gen netliquid = liquid - ccdebt
gen netliq_earnings_ratio = netliquid / earnings if (earnings > 1000)

label variable pdeposits "deposits"
label variable pbonds "government and corporate bonds"
label variable pliqequity "stocks and mutual funds"
label variable liquid "liquid assets"
label variable ccdebt "credit card debt"
label variable netliquid "net liquid assets"
label variable netliq_earnings_ratio "net liquid assets to earnings ratio"

#delimit ;
local stats pdeposits pbonds pliqequity liquid ccdebt earnings
	netliquid netliq_earnings_ratio;
#delimit cr

local meanstats
local medianstats
foreach var of local stats {
	local varlab: variable label `var'
	
	gen mean_`var' = `var'
	gen median_`var' = `var'
	label variable mean_`var' "Mean `varlab'"
	label variable median_`var' "Median `varlab'"
	local meanstats `meanstats' (mean) mean_`var'
	local medianstats `medianstats' (median) median_`var'
}

gen earnwk = earnings / 52
gen nla_lt_biweeklyearn = (netliquid < (2 * earnwk))
gen nla_lt_monthlyearn = (netliquid < (4 * earnwk))
gen nla_lt_annearn = (netliquid < earnings)
drop earnwk

label variable nla_lt_biweeklyearn "Share with net liquid assets < 2 weeks earnings"
label variable nla_lt_monthlyearn "Share with net liquid assets < 4 weeks earnings"
label variable nla_lt_annearn "Share with net liquid assets < annual earnings"

foreach var of varlist nla_lt* {
	local meanstats `meanstats' (mean) `var'
}

// COLLAPSE

gen nworkers_unw = 1
label variable nworkers_unw "n, unwtd"

gen nworkers_wt = 1
label variable nworkers_wt "Total workers in group"

// gen alloccs = 1
// label variable alloccs "Occupation"
// label define alloccs_lbl 1 "All workers"
// label values alloccs alloccs_lbl

discard
local xlxname "$SIPPout/SIPP_wfh_by_occ3digit.xlsx"

local title `"Dataset: SIPP"'
local title `"`title'"' `"Title: WFH and asset ownership"'
local title `"`title'"' `"Date: $S_DATE"'
local title `"`title'"' `"Time: $S_TIME"'

.descriptions = .statalist.new
.descriptions.append "By occupation"
.descriptions.append "By employment status"

.sheets = .descriptions.copy
.sheets = .descriptions.copy
sl_createxlsx .descriptions .sheets using "`xlxname'", title(`title')

.sheets.loop_reset
local byvars occ3d2010 employment
foreach byvar of local byvars {
	.sheets.loop_next
	#delimit ;
	collapse2excel
		(sum) nworkers_wt
		(rawsum) nworkers_unw
		(mean) workfromhome
		`meanstats'
		`medianstats'
		[iw=wpfinwgt]
		using "`xlxname'", by(`byvar') modify sheet("`.sheets.loop_get'");
	#delimit cr
}
