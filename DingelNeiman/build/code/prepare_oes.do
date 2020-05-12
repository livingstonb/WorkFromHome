/*
Reads 2017 OES data into Stata and calls cleaning routines, then resaves.
*/

// Prepare OES 6-digit occs for merge
import excel "../OES/build/input/nat3d2017", clear firstrow

* Clean
do "../OES/build/code/clean_oes_generic.do" 2017 1

* Merge with sector
do "../OES/build/code/merge_with_sector.do"

save "build/temp/nat3d2017.dta", replace
