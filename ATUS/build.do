
macro drop _all
global maindir "/home/brian/Documents/GitHub/WFH/ATUS"
global datadir "$maindir/data"

* Leave module
cd "$maindir"
clear
global rawdata "$datadir/raw/ATUS_leave.dat"
do "$datadir/raw/ATUS_leave.do"
gen leavemod = 1
save "$datadir/temp/leave.dta", replace

* Respondents data, 2017-2018
clear
global rawdata "$datadir/raw/ATUS_respondents2017.dat"
do "$datadir/raw/ATUS_respondents2017.do"
save "$datadir/temp/respondents2017.dta", replace

clear
global rawdata "$datadir/raw/ATUS_respondents2018.dat"
do "$datadir/raw/ATUS_respondents2018.do"
save "$datadir/temp/respondents2018.dta", replace

* ATUS-CPS data, 2017-2018
cd "$maindir"
#delimit ;
local cpsvars
	tucaseid gtmetsta
	tulineno pemaritl
	peeduca gestfips;
#delimit cr

clear
global rawdata "$datadir/raw/ATUS_cps2017.dat"
do "$datadir/raw/ATUS_cps2017.do"

keep `cpsvars'
keep if (tulineno == 1)
save "$datadir/temp/cps2017.dta", replace

clear
global rawdata "$datadir/raw/ATUS_cps2018.dat"
do "$datadir/raw/ATUS_cps2018.do"

keep `cpsvars'
keep if (tulineno == 1)
save "$datadir/temp/cps2018.dta", replace

* Activity Summary data, 2017-2018
cd "$maindir"
#delimit ;
local sumvars
	tucaseid teage tesex
	ptdtrace  pehspnon temjot;
#delimit cr

clear
global rawdata "$datadir/raw/ATUS_sum2017.dat"
do "$datadir/raw/ATUS_sum2017.do"

keep `sumvars'
save "$datadir/temp/sum2017.dta", replace

clear
global rawdata "$datadir/raw/ATUS_sum2018.dat"
do "$datadir/raw/ATUS_sum2018.do"

keep `sumvars'
save "$datadir/temp/sum2018.dta", replace

* Merge files
capture mkdir "$datadir/temp"
cd "$datadir/temp"
use "leave.dta", clear

merge 1:1 tucaseid using "cps2017.dta", keep(1 3 4) nogen update
merge 1:1 tucaseid using "cps2018.dta",  keep(1 3 4) nogen update
merge 1:1 tucaseid using "respondents2017.dta", keep(1 3 4) nogen update
merge 1:1 tucaseid using "respondents2018.dta", keep(1 3 4) nogen update
merge 1:1 tucaseid using "sum2017.dta", keep(1 3 4) nogen update
merge 1:1 tucaseid using "sum2018.dta",keep(1 3 4) nogen update
save "merged.dta", replace

do "$maindir/clean.do"
