clear

local docpath "/media/hdd/GitHub/WorkFromHome/other/industryindex2018.xlsx"
import excel "`docpath'",  firstrow

rename census industry
drop description
label variable industry "Industry, census code"

label variable sector "Sector, aggregate of industry"
label define sector_lbl 0 "C" 1 "S"
label values sector sector_lbl

gen year = 2018

local datpath "/media/hdd/GitHub/WorkFromHome/other/industryindex2018.dta"
compress
save "`datpath'", replace
