/* --- HEADER ---
This script reads raw data from the .dat files and merges
the various datasets.
*/

* Leave module
clear
`#PREREQ' do "build/input/lvresp_1718.do"
gen leavemod = 1
save "build/temp/leave.dta", replace

* Respondents data, 2017-2018
clear
`#PREREQ' do "build/input/atusresp_2017.do"
save "build/temp/respondents2017.dta", replace

clear
`#PREREQ' do "build/input/atusresp_2018.do"
save "build/temp/respondents2018.dta", replace

global rawdata

* ATUS-CPS data, 2017-2018
#delimit ;
local cpsvars tucaseid gtmetsta
	tulineno pemaritl peeduca gestfips;
#delimit cr

clear
`#PREREQ' do "build/input/atuscps_2017.do"

keep `cpsvars'
keep if (tulineno == 1)
save "build/temp/cps2017.dta", replace

clear
`#PREREQ' do "build/input/atuscps_2018.do"

keep `cpsvars'
keep if (tulineno == 1)
save "build/temp/cps2018.dta", replace

* Activity Summary data, 2017-2018
#delimit ;
local sumvars tucaseid teage tesex
	ptdtrace  pehspnon temjot;
#delimit cr

clear
`#PREREQ' do "build/input/atussum_2017.do"

keep `sumvars'
save "build/temp/sum2017.dta", replace

clear
`#PREREQ' do "build/input/atussum_2018.do"

keep `sumvars'
save "build/temp/sum2018.dta", replace

* Merge files
use "build/temp/leave.dta", clear

merge 1:1 tucaseid using "build/temp/respondents2017.dta", keep(1 3 4) nogen update
merge 1:1 tucaseid using "build/temp/respondents2018.dta", keep(1 3 4) nogen update
merge 1:1 tucaseid using "build/temp/sum2017.dta", keep(1 3 4) nogen update
merge 1:1 tucaseid using "build/temp/sum2018.dta",keep(1 3 4) nogen update
merge 1:1 tucaseid using "build/temp/cps2017.dta", keep(1 3 4) nogen update
merge 1:1 tucaseid using "build/temp/cps2018.dta",  keep(1 3 4) nogen update
`#TARGET' save "build/temp/atus_combined.dta", replace
