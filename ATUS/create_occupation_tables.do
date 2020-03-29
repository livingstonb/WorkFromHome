cd "$ATUSdir"
use "$ATUSdata/cleaned/ATUS_cleaned.dta", clear

* Gen new variables
gen pct_canwfh = 100 * canwfh
label variable pct_canwfh "% can WFH"

gen pct_doeswfh = 100 * doeswfh
label variable pct_doeswfh "% does WFH"

gen nworkers_unw = 1
label variable nworkers_unw "n, unwtd"

gen nworkers_wt = 1
label variable nworkers_wt "Total workers in group"

gen meanwage = earnwk * 52 if (singjob_fulltime == 1)
label variable meanwage "Mean (wkly earnings * 52), full-time single jobholders only"

* Add empty observations so each occupation is represented
forvalues sval = 0/1 {
	append using "$WFHshared/occblanks.dta", gen(indicator`sval')
	replace sector = `sval' (if indicator`sval' == 1)
	replace occ3digit = occ3d2010 if (blankobs == 1)
}
drop indicator*

foreach var of varlist nworkers_unw nworkers_wt {
	replace `var' = 0 if (blankobs == 1)
}

replace blankobs = 0 if missing(blankobs)
label variable blankobs "Empty category"

* Collapse and make spreadsheet
discard
local xlxname "$ATUSout/ATUS_wfh_by_occ3digit_sector.xlsx"

local title `"Dataset: ATUS"'
local title `"`title'"' `"WFH statistics by 3-digit occupation"'

local sheets `"Sector C"' `"Sector S"'
local descriptions `"Sector C only"' `"Sector S only"'

#delimit ;
createxlsx using "`xlxname'",
	descriptions(`descriptions') sheetnames(`sheets') title(`title');
#delimit cr

forvalues sval = 0/1 {
	#delimit ;
	
	local snum = `sval' + 1;
	local sheetname: word `snum' of `"`sheets'"';

	collapse2excel
		(sum) nworkers_wt
		(rawsum) nworkers_unw
		(mean) pct_canwfh
		(mean) pct_doeswfh
		(mean) meanwage
		(min) blankobs
		[iw=normwt] if (sector == `sval')
		using "`xlxname'", by(occ3digit) modify sheet("`sheetname'");
	#delimit cr
}
