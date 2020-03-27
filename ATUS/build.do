
* Leave module
cd "$ATUSdir"
clear
global rawdata "$ATUSdata/raw/ATUS_leave.dat"
do "$ATUSdata/raw/ATUS_leave.do"
gen leavemod = 1
save "$ATUSdata/temp/leave.dta", replace

* Respondents data, 2017-2018
clear
global rawdata "$ATUSdata/raw/ATUS_respondents2017.dat"
do "$ATUSdata/raw/ATUS_respondents2017.do"
save "$ATUSdata/temp/respondents2017.dta", replace

clear
global rawdata "$ATUSdata/raw/ATUS_respondents2018.dat"
do "$ATUSdata/raw/ATUS_respondents2018.do"
save "$ATUSdata/temp/respondents2018.dta", replace

* ATUS-CPS data, 2017-2018
cd "$ATUSdir"
#delimit ;
local cpsvars
	tucaseid gtmetsta
	tulineno pemaritl
	peeduca gestfips;
#delimit cr

clear
global rawdata "$ATUSdata/raw/ATUS_cps2017.dat"
do "$ATUSdata/raw/ATUS_cps2017.do"

keep `cpsvars'
keep if (tulineno == 1)
save "$ATUSdata/temp/cps2017.dta", replace

clear
global rawdata "$datadir/raw/ATUS_cps2018.dat"
do "$ATUSdata/raw/ATUS_cps2018.do"

keep `cpsvars'
keep if (tulineno == 1)
save "$ATUSdata/temp/cps2018.dta", replace

* Activity Summary data, 2017-2018
cd "$ATUSdir"
#delimit ;
local sumvars
	tucaseid teage tesex
	ptdtrace  pehspnon temjot;
#delimit cr

clear
global rawdata "$ATUSdata/raw/ATUS_sum2017.dat"
do "$ATUSdata/raw/ATUS_sum2017.do"

keep `sumvars'
save "$ATUSdata/temp/sum2017.dta", replace

clear
global rawdata "$ATUSdata/raw/ATUS_sum2018.dat"
do "$ATUSdata/raw/ATUS_sum2018.do"

keep `sumvars'
save "$ATUSdata/temp/sum2018.dta", replace

* Merge files
capture mkdir "$ATUSdata/temp"
cd "$ATUSdata/temp"
use "leave.dta", clear

merge 1:1 tucaseid using "cps2017.dta", keep(1 3 4) nogen update
merge 1:1 tucaseid using "cps2018.dta",  keep(1 3 4) nogen update
merge 1:1 tucaseid using "respondents2017.dta", keep(1 3 4) nogen update
merge 1:1 tucaseid using "respondents2018.dta", keep(1 3 4) nogen update
merge 1:1 tucaseid using "sum2017.dta", keep(1 3 4) nogen update
merge 1:1 tucaseid using "sum2018.dta",keep(1 3 4) nogen update
save "merged.dta", replace

do "$ATUSdir/clean.do"
