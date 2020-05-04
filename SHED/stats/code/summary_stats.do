/* --- HEADER ---
Computes summary statistics for SHED.
*/

clear
adopath + "../ado"

`#PREREQ' local cleaned "build/output/shed_cleaned.dta"
use "`cleaned'"

// SAMPLE SELECTION
keep if (age >= 15)

// NORMALIZE WEIGHTS
quietly sum wgt if (year == 2018)
local wgt2018 = `r(sum)'

forvalues yr = 2013/2017 {
	quietly sum wgt if (year == `yr')
	local wgt`yr' = `r(sum)'
	replace wgt = wgt * `wgt2018' / `wgt`yr'' if (year == `yr')
}

// TABLES

* Add blanks
`#PREREQ' local occ2010 "../occupations/build/output/census2010_to_soc2010.dta"
#delimit ;
appendblanks soc2d2010 using "`occ2010'";
#delimit cr
replace wgt = 1 if blankobs

* Collect variables for collapse
#delimit ;
* Unable to pay bills;
.paybills_h2m = .collapsevar.new paybills_h2m, cmd(mean) counts
	colname("Unable to pay all bills in full this month");

* Unable to pay bills if $400 expense;
.paybills400_h2m = .collapsevar.new paybills400_h2m,
	cmd(mean) counts colname(
	"Unable to pay all bills in full this month
	if there is a $400 emergency expense
	(modified to at least include households
	from previous question)");

* Often only paid min credit card pament;
.ccmin_h2m = .collapsevar.new ccmin_h2m,
	cmd(mean) counts colname(
		"In the past 12 months, most or all of the time
		have only paid the minimum payment on
		one or more of your credit cards.");

* Rainy day;
.rainyday_h2m = .collapsevar.new rainyday_h2m,
	cmd(mean) counts colname(
		"Do not have rainy day funds
		that would cover 3 months of expenses in the
		case of emergency");

* Would not be able to cover expenses;
.coverexpenses_h2m = .collapsevar.new coverexpenses_h2m,
	cmd(mean) counts colname(
		"If respondent were to lose
		his/her main source of income, would not be able
		to cover 3 months of expenses by borrowing, using
		savings, or selling assets");

* Income <= spending;
.spendinc_h2m = .collapsevar.new spendinc_h2m,
	cmd(mean) counts colname(
		"Income was less than or equal to spending");

* Could not cover emerg expense by any means;
.emerg_h2m = .collapsevar.new emerg_h2m,
	cmd(mean) counts colname(
		"Could not cover a $400 expense
		right now (by essentially any means)");

.blankobs = .collapsevar.new blankobs,
	cmd(min) colname("Empty category");

* Collect variables;
local cvars .paybills_h2m .paybills400_h2m
	.ccmin_h2m .rainyday_h2m .coverexpenses_h2m
	.emerg_h2m .blankobs;
#delimit cr

label variable wfhflex "Occupation"
label define flexlbl 0 "WFH-Rigid" 1 "WFH-Flexible"
label values wfhflex flexlbl

.wfhflex = .collapsevar.new wfhflex, cmd(firstnm)
.sector = .collapsevar.new cvsector

.xlxnotes = .statalist.new
.xlxnotes.append "Dataset: SHED"
.xlxnotes.append "Sample: 2014 and 2016"
.xlxnotes.append "Description: HtM statistics"

`#TARGET' local xlxname "stats/output/SHED_HtM.xlsx"

.descriptions = .statalist.new
.descriptions.append "All respondents"
.descriptions.append "All workers"
.descriptions.append "5 occupation groups"
.descriptions.append "A 2x2 economy"
.descriptions.append "Stats by 2-digit occupation"
.sheets = .descriptions.copy
createxlsx .descriptions .sheets .xlxnotes using "`xlxname'"
.sheets.loop_reset

* All respondents
gen all_resp = 1
.all_resp = .collapsevar.new all_resp
label variable all_resp "All respondents"

.sheets.loop_next
#delimit ;
collapsecustom `cvars' [iw=wgt] using "`xlxname'",
	by(.all_resp) modify sheet("`.sheets.loop_get'");
#delimit cr

* All 5 occupation groups
gen all_workers = 1 if !missing(occ_group)
.all_workers = .collapsevar.new all_workers
label variable all_workers "All workers"

.sheets.loop_next
#delimit ;
collapsecustom `cvars' [iw=wgt] using "`xlxname'",
	by(.all_workers) modify sheet("`.sheets.loop_get'");
#delimit cr

* Each of the 5 occupation groups
.occ_group = .collapsevar.new occ_group
label variable occ_group "Occupation"

.sheets.loop_next
#delimit ;
collapsecustom `cvars' [iw=wgt] using "`xlxname'",
	by(.occ_group) modify sheet("`.sheets.loop_get'");
#delimit cr

* In 2x2 economy
.sheets.loop_next
#delimit ;
collapsecustom `cvars' [iw=wgt] using "`xlxname'" if inlist(year, 2014, 2016),
	by(.wfhflex .sector) modify sheet("`.sheets.loop_get'");
#delimit cr

* By 2-digit occupation
.soc2d2010 = .collapsevar.new soc2d2010
label variable soc2d2010 "Occupation"

.sheets.loop_next
#delimit ;
collapsecustom .wfhflex `cvars' [iw=wgt] using "`xlxname'" if inlist(year, 2014, 2016),
	by(.soc2d2010) modify sheet("`.sheets.loop_get'");
#delimit cr
