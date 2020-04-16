/* --- HEADER ---
This script computes various asset, earnings, and WFH statistics
for SIPP and outputs them to a spreadsheet.

#PREREQ ../ado/statalist.class
#PREREQ ../ado/createxlsx.ado
#PREREQ ../ado/collapse2excel.ado
*/

adopath + "../ado"

`#PREREQ' use "build/output/sipp_cleaned.dta", clear

// MEAN AND MEDIAN VARIABLES FOR COLLAPSE
#delimit ;
local stats pdeposits pbonds pliqequity liquid_nocash liquid_wcash ccdebt earnings
	netliquid netliq_earnings_ratio netilliquid;
#delimit cr

label variable foodinsecure "Share who cut or skipped meals b/c not enough money"
label variable qualitative_h2m "Share who cut or skipped meals or couldn't pay utilities"

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

foreach var of varlist qualitative_h2m foodinsecure nla* whtm* phtm* {
	local meanstats `meanstats' (mean) `var'
}

gen nworkers_unw = !missing(workfromhome)
label variable nworkers_unw "n, unwtd"

gen nworkers_wt = !missing(workfromhome)
label variable nworkers_wt "Total"

* Add blanks
tempfile yrtmp
preserve
clear
save `yrtmp', emptyok
`#PREREQ' local occsipp "../occupations/build/output/occindexSIPP.dta"
forvalues wave = 1/4 {
forvalues sval = 0/1 {
	use soc3d2010 using "`occsipp'", clear
	gen sector = `sval'
	gen swave = `wave'
	gen wpfinwgt = 1
	gen blankobs = 1
	rename soc3d2010 occ3d2010
	
	append using `yrtmp'
	save `yrtmp', replace
}
}
restore
append using `yrtmp'

replace blankobs = 0 if missing(blankobs)
label variable blankobs "Empty category"

// COLLAPSE TO dta
preserve

drop if missing(sector, occ3d2010)

rename workfromhome pct_workfromhome
rename earnings meanwage

#delimit ;
collapse
	(sum) nworkers_wt (rawsum) nworkers_unw
	(mean) pct_workfromhome (mean) meanwage
	`meanstats' `medianstats'
	(min) blankobs
	[iw=wpfinwgt], by(sector occ3d2010) fast;
#delimit cr

drop mean_earnings
drop median_earnings
gen source = "SIPP"

`#TARGET' save "stats/output/SIPPwfh.dta", replace
restore

// COLLAPSE TO EXCEL
foreach wave of numlist 1 2 3 4 0 {
if `wave' == 0 {
	local wlab "pooled"
	local samples "Waves 1-4"
}
else {
	local wlab "w`wave'"
	local samples "Wave `wave'"
}
local xlxname "stats/output/SIPP_wfh_`wlab'.xlsx"

.xlxnotes = .statalist.new
.xlxnotes.append "Dataset: SIPP"
.xlxnotes.append "Sample: 2014 `samples'"
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
createxlsx .descriptions .sheets .xlxnotes using "`xlxname'"

.sheets.loop_reset
local byvars occ3d2010 employment
foreach byvar of local byvars {
forvalues sval = 0/2 {
	if ("`byvar'" == "employment") & (`sval' < 2) {
		continue
	}

	if `sval' < 2 {
		if `wave' != 0 {
			local restrictions "if (sector == `sval') & (swave == `wave')"
		}
		else {
			local restrictions "if (sector == `sval')"
		}
	}
	else {
		if `wave' != 0 {
			local restrictions "if (swave == `wave')"
		}
		else {
			local restrictions
		}
	}
		
	.sheets.loop_next
	#delimit ;
	collapse2excel
		(sum) nworkers_wt
		(rawsum) nworkers_unw
		(mean) workfromhome
		(mean) mworkfromhome
		`meanstats'
		`medianstats'
		(min) blankobs
		[iw=wpfinwgt] `restrictions'
		using "`xlxname'",
		by(`byvar') modify sheet("`.sheets.loop_get'");
	#delimit cr
}
}
}
