/* --- MAKEFILE INSTRUCTIONS ---
*/

/* This do-file maps NAICS industry categories to sectors C and S. */
clear
local MAKEREQ "build/input/naics_to_sector.csv"
import delimited "`MAKEREQ'", bindquotes(strict)

drop v1
drop if missing(sector)
label define sector_lbl 0 "C" 1 "S"
label values sector sector_lbl

local MAKETARGET "build/output/naicsindex2017.dta"
save "`MAKETARGET'", replace
