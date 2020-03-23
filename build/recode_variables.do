
label drop _all
label define bin_lbl 0 "No" 1 "Yes"

* Read data after coding missing values
use "$build/temp/acs_temp.dta", clear