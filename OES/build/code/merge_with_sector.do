
gen naicsnum = subinstr(naicscode, "-", "", .)
destring naicsnum, replace force

gen int ind3d = naicsnum / 1000
gen int ind2d = floor(ind3d / 10)
gen int ind1d = floor(ind3d / 100)
drop naicsnum

local naicsdta "../industries/build/output/naicsindex2017.dta"

* 1-digit first
rename ind1d naics2017
#delimit ;
merge m:1 naics2017 using "`naicsdta'",
	keepusing(sector) keep(1 3 4) nogen update;
#delimit cr
rename naics2017 ind1d

* 2-digit
rename ind2d naics2017
#delimit ;
merge m:1 naics2017 using "`naicsdta'",
	keepusing(sector) keep(1 3 4) nogen update;
#delimit cr
rename naics2017 ind2d

* 3-digit
rename ind3d naics2017
#delimit ;
merge m:1 naics2017 using "`naicsdta'",
	keepusing(sector) keep(1 3 4) nogen update;
#delimit cr
rename naics2017 ind3d