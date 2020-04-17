/* --- HEADER ---
This script computes various asset, earnings, and WFH statistics
for SIPP and outputs them to a spreadsheet.
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

local cvars
foreach var of local stats {
	local varlab: variable label `var'
	
	gen mean_`var' = `var'
	gen median_`var' = `var'
	
	#delimit ;
	.`var' = .collapsevar.new `var',
		cmd(mean median) colname(
		"Mean `varlab' | Median `varlab'");
	#delimit cr
	
	local cvars `cvars' .`var'
}

foreach var of varlist qualitative_h2m foodinsecure nla* whtm* phtm* {
	#delimit ;
	.`var' = .collapsevar.new `var',
		cmd(mean) colname("");
	#delimit cr
	
	local cvars `cvars' .`var'
}

gen nworkers_unw = !missing(workfromhome)
label variable nworkers_unw "n, unwtd"

gen nworkers_wt = !missing(workfromhome)
label variable nworkers_wt "Total"

.nworkers_unw = .collapsevar.new nworkers_unw, cmd(rawsum)
.nworkers_wt = .collapsevar.new nworkers_wt, cmd(sum)

.occ3d2010 = .collapsevar.new occ3d2010
.employment = .collapsevar.new employment

* Add blanks
`#PREREQ' local occ2010 "../occupations/build/output/occindexSIPP.dta"
#delimit ;
appendblanks soc3d2010 using "`occ2010'",
	gen(blankobs) over1(sector) values1(0 1)
	over2(swave) values2(0 1) rename(occ3d2010);
#delimit cr
.blankobs = .collapsevar.new blankobs, cmd(min)

replace nworkers_wt = 0 if blankobs
replace nworkers_unw = 0 if blankobs
label variable blankobs "Empty category"

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
// 	#delimit ;
// 	collapse2excel
// 		(sum) nworkers_wt (rawsum) nworkers_unw
// 		(mean) workfromhome (mean) mworkfromhome
// 		`meanstats' `medianstats'
// 		(min) blankobs [iw=wpfinwgt] `restrictions'
// 		using "`xlxname'",
// 		by(`byvar') modify sheet("`.sheets.loop_get'");
// 	#delimit cr

	#delimit ;
	collapsecustom `cvars' [iw=wpfinwgt] `restrictions'
		using "`xlxname'", by(.`byvar')
		modify sheet("`.sheets.loop_get'");
	#delimit cr
}
}
}
