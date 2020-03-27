// WFH BY OCCUPATION, THREE DIGIT
cd "$stats"
use "$build/cleaned/acs_cleaned.dta" if (year == 2018), clear
drop if missing(sector, occfine)

label define bin_lbl 0 "No" 1 "Yes", replace
label define bin_pct_lbl 0 "No" 100 "Yes", replace

gen wfh_yrs2018 = 100 * workfromhome if (year == 2018)
label variable wfh_yrs2018 "%WFH, 2018 only"
label values wfh_yrs2018 bin_pct_lbl

* Merge with WFH stats by occupation
#delimit ;
merge m:1 occfine using "$build/cleaned/occ_group_stats.dta",
	keepusing(meanwage_2occ wfhflex3digit) nogen;
#delimit cr

gen nworkers_unw = 1
label variable nworkers_unw "n, unwtd"

gen nworkers_wt = 1
label variable nworkers_wt "Total workers in group"

gen meanwage = incwage
label variable meanwage "Mean wage/salary income"

local sheet1 "Sector C"
local sheet2 "Sector S"
local xlxname "$statsout/wfh_by_occ3digit_sector.xlsx"

putexcel set "`xlxname'", replace sheet("Contents")
putexcel A1 = "SHEET" B1 = "DESCRIPTION"
putexcel A2 = "1" B2 = "`sheet1'"
putexcel A3 = "2" B3 = "`sheet2'"

titlepage2excel using "`xlxname'", descriptions(`')

forvalues sval = 0/1 {
	#delimit ;

	local sheetnum = `sval' + 1;
	local sheetname `sheet`sheetnum'';

	collapse2excel
		(sum) nworkers_wt
		(rawsum) nworkers_unw
		(mean) wfh_yrs2018
		(mean) meanwage
		[iw=perwt] if (sector == `sval')
		using "`xlxname'", by(occfine)
		sheet("`sheetname'") title("`sheetname'");
	#delimit cr
}
drop nworkers_unw nworkers_wt meanwage
