
use "$SIPPout/sipp_cleaned.dta", clear


// MEAN AND MEDIAN VARIABLES FOR COLLAPSE
#delimit ;
local stats pdeposits pbonds pliqequity liquid ccdebt earnings
	netliquid netliq_earnings_ratio netilliquid;
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

tempvar earnwk
gen `earnwk' = earnings / 52

gen nla_lt_biweeklyearn = (netliquid < (2 * `earnwk'))
label variable nla_lt_biweeklyearn "Share with net liquid assets < 2 weeks earnings"

gen nla_lt_monthlyearn = (netliquid < (4 * `earnwk'))
label variable nla_lt_monthlyearn "Share with net liquid assets < 4 weeks earnings"

gen nla_lt_annearn = (netliquid < earnings)
label variable nla_lt_annearn "Share with net liquid assets < annual earnings"

gen whtm_biweeklyearn = (netliquid < (2 * `earnwk')) * (netilliquid >= 10000)
label variable whtm_biweeklyearn "Share WHtM (NLIQ < 2 wks earnings and NILLIQ >= $10000)"

gen whtm_monthlyearn = (netliquid < (4 * `earnwk')) * (netilliquid >= 10000)
label variable whtm_monthlyearn "Share WHtM (NLIQ < 4 wks earnings and NILLIQ >= $10000)"


foreach var of varlist nla_lt* whtm* {
	local meanstats `meanstats' (mean) `var'
}

* Add blanks
tempfile yrtmp
preserve
clear
save `yrtmp', emptyok
forvalues sval = 0/1 {
	use occ3d2010 using "$WFHshared/occsipp/output/occindexsipp.dta", clear
	gen sector = `sval'
	gen wpfinwgt = 1
	gen blankobs = 1
	
	append using `yrtmp'
	save `yrtmp', replace
}
restore
append using `yrtmp'
// drop if (occ3d2010 >= 550) & !missing(occ3d2010)

replace blankobs = 0 if missing(blankobs)
label variable blankobs "Empty category"

// COLLAPSE

gen nworkers_unw = 1
label variable nworkers_unw "n, unwtd"

gen nworkers_wt = 1
label variable nworkers_wt "Total"

replace nworkers_wt = 0 if (blankobs == 1)
replace nworkers_unw = 0 if (blankobs == 1)

discard
local xlxname "$SIPPout/SIPP_wfh_by_occ3digit.xlsx"

.xlxnotes = .statalist.new
.xlxnotes.append "Dataset: SIPP"
.xlxnotes.append "Sample: 2014 Wave 4"
.xlxnotes.append "Sampling unit: Individual"
.xlxnotes.append "Description: WFH and asset ownership"
.xlxnotes.append ""
.xlxnotes.append "NET LIQUID ASSETS = deposits + bonds + stocks + mutual funds - ccdebt"
.xlxnotes.append "NET ILLIQUID ASSETS = home equity + retirement accounts + CDs + life insurance"
.xlxnotes.append ""

.descriptions = .statalist.new
.descriptions.append "Sector C, by occ"
.descriptions.append "Sector S, by occ"
.descriptions.append "Both sectors, by occ"
.descriptions.append "Both sectors, by empl"

.sheets = .descriptions.copy
.sheets = .descriptions.copy
createxlsx .descriptions .sheets .xlxnotes using "`xlxname'"

.sheets.loop_reset
local byvars occ3d2010 employment
foreach byvar of local byvars {
forvalues sval = 0/2 {
	if ("`byvar'" == "employment") & (`sval' < 2) {
		continue
	}

	if `sval' < 2 {
		local restrictions "if (sector == `sval')"
	}
	else {
		local restrictions
	}

	.sheets.loop_next
	#delimit ;
	collapse2excel
		(sum) nworkers_wt
		(rawsum) nworkers_unw
		(mean) workfromhome
		`meanstats'
		`medianstats'
		(min) blankobs
		`restrictions' [iw=wpfinwgt]
		using "`xlxname'",
		by(`byvar') modify sheet("`.sheets.loop_get'");
	#delimit cr
}
}
