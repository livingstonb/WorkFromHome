/* --- MAKEFILE INSTRUCTIONS ---
*/

/* This do-file maps NAICS industry categories to sectors C and S. */
clear
`#PREREQ' local naics "build/input/naics_to_sector.csv"
import delimited "`naics'", bindquotes(strict)

drop v1
drop if missing(sector)
label define sector_lbl 0 "C" 1 "S"
label values sector sector_lbl

`#TARGET' save "build/output/naicsindex2017.dta", replace
