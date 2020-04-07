// NOTE: FIRST RUN "do macros.do" IN THE MAIN DIRECTORY

/* Dataset: SHED */
/* This do-file computes summary statistics for SHED. */

clear
use if inlist(year, 2014, 2016) using "$SHEDout/SHED.dta"

// NORMALIZE WEIGHTS
quietly sum wgt if (year == 2014)
local wgt2014 = `r(sum)'

quietly sum wgt if (year == 2016)
local wgt2016 = `r(sum)'

replace wgt = wgt * `wgt2016' / `wgt2014' if year == 2014

// SAMPLE SELECTION
keep if (age >= 15)

// TABLES
drop havemoney_h2m ccunpaid_h2m
local cvars
foreach var of varlist *_h2m {
	.`var' = .collapsevar.new
	.`var'.set `var', cmd(mean) counts
	local cvars `cvars' .`var'
}
do "$SHEDstats/set_colnames.do"

gen nobs = 1
label variable nobs "n, unweighted"
.nobs = .collapsevar.new
.nobs.set nobs, cmd(rawsum)

label variable wfhflex "Occupation"
label define flexlbl 0 "WFH-Rigid" 1 "WFH-Flexible"
label values wfhflex flexlbl

.wfhflex = .collapsevar.new
.wfhflex.set wfhflex, cmd(firstnm)

.sector = .collapsevar.new
.sector.set cvsector

.xlxnotes = .statalist.new
.xlxnotes.append "Dataset: SHED"
.xlxnotes.append "Sample: 2014 and 2016"
.xlxnotes.append "Description: HtM statistics"

local xlxname "$SHEDstatsout/SHED_HtM.xlsx"

.descriptions = .statalist.new
.descriptions.append "A 2x2 economy"
.descriptions.append "Stats by 2-digit occupation"
.sheets = .descriptions.copy
createxlsx .descriptions .sheets .xlxnotes using "`xlxname'"
.sheets.loop_reset

* In 2x2 economy
.sheets.loop_next
#delimit ;
collapsecustom .nobs `cvars' [iw=wgt] using "`xlxname'",
	by(.wfhflex .sector) modify sheet("`.sheets.loop_get'");
#delimit cr

* By 2-digit occupation
.soc2d2010 = .collapsevar.new
.soc2d2010.set soc2d2010
label variable soc2d2010 "Occupation"

.sheets.loop_next
#delimit ;
collapsecustom .nobs .wfhflex `cvars' [iw=wgt] using "`xlxname'",
	by(.soc2d2010) modify sheet("`.sheets.loop_get'");
#delimit cr
