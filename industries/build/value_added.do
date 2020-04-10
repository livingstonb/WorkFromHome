/* --- MAKEFILE INSTRUCTIONS ---
*/

/* Dataset: SIPP */
/* This script reads the .dta file after it has been split into chunks,
cleaned somewhat, and recombined. Various variables are recoded and 
new variables are generated. */

clear

`#PREREQ' local bea_in "build/input/bea_value_added_sector.csv"
import delimited "`bea_in'", varnames(1)
replace description = strtrim(description)

label define sector_lbl 0 "C" 1 "S"
label values sector sector_lbl

`#TARGET' local bea_out "build/output/bea_value_added_sector.dta"
save "`bea_out'", replace
