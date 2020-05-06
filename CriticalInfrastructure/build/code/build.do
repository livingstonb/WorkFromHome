

clear

`#PREREQ' 
#delimit ;
import delimited using "build/input/soc_critical_infrastructure.csv",
	clear bindquotes(strict) varnames(1);
#delimit cr

foreach var of varlist _all {
	replace `var' = strtrim(`var')
}

* Use 5-digit where available
replace critical = "1" if (critical == "X")
replace critical = "0" if (critical == "")
destring critical, force replace

gen soc5d2010 = substr(soc2010, 1, 6)
replace soc5d2010 = subinstr(soc5d2010, "-", "", .)
destring soc5d2010, force replace

capture label drop soc5d2010_lbl
`#PREREQ' do "../occupations/build/output/soc5dlabels2010.do"
label values soc5d2010 soc5d2010_lbl

* Drop non-existent soc5d2010 codes (repeated rows with bad information)
drop if inlist(soc5d2010, 15124, 17309, 29122, 29124, 29129, 31112)
drop if inlist(soc5d2010, 15125, 39109, 53104, 53305)

* Drop military
drop if soc5d2010 > 55000

gen is5digit = substr(soc2010, 7, 1) == "0"
bysort soc5d2010: egen has5digit = max(is5digit)

drop if has5digit & !is5digit

* Recode soc2010 codes that don't line up with 2018
duplicates tag soc2010, gen(dup)
bysort soc5d2010 (critical): gen uniform_critical = (critical[1] == critical[_N])

// replace critical = 0 if 
