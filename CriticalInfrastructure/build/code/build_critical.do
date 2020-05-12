/*
Reads a dataset indicating whether a given SOC code is critical or not critical.
The indicator is aggregated from the 6-digit occupation level to the 5-digit level.
*/

// Read dataset
clear
local empfile "build/input/soc2010_critical.csv"
import delimited using "`empfile'", clear bindquotes(strict) varnames(1)
keep if occ_group == "detailed"
drop occ_group

foreach var of varlist soc2010 critical {
	replace `var' = strtrim(`var')
}

* Recode critical
replace critical = "1" if (critical == "X")
replace critical = "0" if (critical == "")
destring critical, force replace

* 5-digit codes
gen soc5d2010 = substr(soc2010, 1, 6)
replace soc5d2010 = subinstr(soc5d2010, "-", "", .)
destring soc5d2010, force replace

capture label drop soc5d2010_lbl
do "../occupations/build/output/soc5dlabels2010.do"
label values soc5d2010 soc5d2010_lbl

* Take weighted mean
collapse (mean) critical [iw=employment], by(soc5d2010)
gen val_critical = critical
replace critical = 0 if (val_critical < 0.5)
replace critical = 1 if (val_critical > 0.5)

label variable val_critical "Weighted mean of critical indicator"

label variable critical "Critical worker indicator"
label define critical_lbl 0 "Not critical" 1 "Critical"
label values critical critical_lbl

save "build/output/critical5d.dta", replace
