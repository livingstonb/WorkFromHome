

clear

`#PREREQ' 
#delimit ;
import delimited using "build/input/soc_critical_infrastructure.csv",
	clear bindquotes(strict) varnames(1);
#delimit cr

foreach var of varlist _all {
	replace `var' = strtrim(`var')
}

replace critical = "1" if (critical == "X")
replace critical = "0" if (critical == "")
destring critical, force replace

gen is5digit = substr(soc2010, 7, 1) == "0"
gen soc5digit = substr(soc2010, 1, 6)

* Recode soc2010 codes that don't line up with 2018
duplicates tag soc2010, gen(dup)
bysort soc2010 (critical): gen uniform_critical = (critical[1] == critical[_N])

// replace critical = 0 if 
