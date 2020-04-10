/* --- MAKEFILE INSTRUCTIONS ---
*/

/* This do-file maps 2017 Census industry categories to sectors C and S. */
clear

local MAKEREQ "build/input/industryindex2017.xlsx"
import excel "`MAKEREQ'",  firstrow

rename census ind2017
drop description
label variable ind2017 "Industry, 2017 Census code"

label variable sector "Sector, aggregate of industry"
label define sector_lbl 0 "C" 1 "S"
label values sector sector_lbl

* Save
local MAKETARGET "build/output/industryindex2017.dta"
save "`MAKETARGET'", replace