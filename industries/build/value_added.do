/* --- MAKEFILE INSTRUCTIONS ---
*/

/* Dataset: SIPP */
/* This script reads the .dta file after it has been split into chunks,
cleaned somewhat, and recombined. Various variables are recoded and 
new variables are generated. */

clear

local MAKEREQ "build/input/bea_value_added_sector.csv"
import delimited "`MAKEREQ'", varnames(1)
replace description = strtrim(description)

label define sector_lbl 0 "C" 1 "S"
label values sector sector_lbl

local MAKETARGET "build/output/bea_value_added_sector.dta"
save "`MAKETARGET'", replace
