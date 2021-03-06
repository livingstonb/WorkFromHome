/*-
Computes WFH and other statistics by occupation and sector.
*/

use "build/output/atus_cleaned.dta", clear
adopath + "../ado"

rename occ3digit occ3d2010

* Gen new variables
gen pct_canwfh = 100 * canwfh
gen pct_doeswfh = 100 * doeswfh
gen nworkers_wt = !missing(canwfh, doeswfh)

gen meanwage = earnwk * 52 if (singjob_fulltime == 1)
label variable meanwage "Mean (wkly earnings * 52), full-time single jobholders only"

* Add blanks
local blanks "../occupations/build/output/soc3dvalues2010.dta"
#delimit ;
appendblanks soc3d2010 using "`blanks'",
	zeros(nworkers_wt) ones(normwt)
	over1(sector) values1(0 1) rename(occ3d2010);
#delimit cr

drop if (occ3d2010 >= 550) & !missing(occ3d2010)

* Set collapse variables
#delimit ;
.nworkers_wt = .collapsevar.new nworkers_wt,
	cmd(sum) colname("Total workers in group");
.pct_canwfh = .collapsevar.new pct_canwfh,
	cmd(mean) counts colname("% can WFH");
.pct_doeswfh = .collapsevar.new pct_doeswfh,
	cmd(mean) counts colname("% does WFH");
.meanwage = .collapsevar.new meanwage,
	cmd(mean) counts colname(
		"Mean of wkly earnings * 52,
		full-time single jobholders only");
.blankobs = .collapsevar.new blankobs,
	cmd(min) colname("Empty category");
.occ3d2010 = .collapsevar.new occ3d2010,
	colname("Occupation");

local cvars .nworkers_wt .pct_canwfh .pct_doeswfh
	.meanwage .blankobs;
#delimit cr

* Collapse and make .dta file
preserve
rename pct_doeswfh pct_workfromhome
drop if missing(occ3d2010, sector)

gen nworkers_unw = 1 if !blankobs
#delimit ;
collapse (sum) nworkers_wt
		(rawsum) nworkers_unw
		(mean) pct_canwfh
		(mean) pct_workfromhome
		(mean) meanwage
		(min) blankobs
		[iw=normwt], by(occ3d2010 sector) fast;
#delimit cr

gen source = "ATUS"
save "stats/output/ATUSwfh.dta", replace
restore

* Collapse and make spreadsheet
local xlxname "stats/output/ATUS_wfh_by_occ.xlsx"

.xlxnotes = .statalist.new
.xlxnotes.append "Dataset: ATUS"
.xlxnotes.append "Sample: 2017-2018 with Leave Module"
.xlxnotes.append "Description: WFH statistics by 3-digit occupation"

.descriptions = .statalist.new
.descriptions.append "Sector C"
.descriptions.append "Sector S"
.sheets = .descriptions.copy
createxlsx .descriptions .sheets .xlxnotes using "`xlxname'"

.sheets.loop_reset
forvalues sval = 0/1 {
	.sheets.loop_next

	#delimit ;
	collapsecustom `cvars' [iw=normwt] if (sector == `sval')
		using "`xlxname'", by(.occ3d2010)
		modify sheet("`.sheets.loop_get'");
	#delimit cr
}
