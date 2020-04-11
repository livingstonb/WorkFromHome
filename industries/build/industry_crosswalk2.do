/* --- HEADER ---
This do-file maps 2017 Census industry categories to sectors C and S.
*/

clear

`#PREREQ' local index17 "build/input/industryindex2017.xlsx"
import excel "`index17'",  firstrow

rename census ind2017
label variable ind2017 "Industry, 2017 Census code"

label variable sector "Sector, aggregate of industry"
label define sector_lbl 0 "C" 1 "S"
label values sector sector_lbl

drop description

* Save
`#TARGET' local out17 "build/output/industryindex2017.dta"
save "`out17'", replace