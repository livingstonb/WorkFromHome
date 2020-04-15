
tempvar naicsnumeric
gen `naicsnumeric' = subinstr(naicscode, "-", "", .)
destring `naicsnumeric', force replace

tempvar ind1d ind2d ind3d
gen int `ind3d' = `naicsnumeric' / 1000
gen int `ind2d' = floor(`ind3d' / 10)
gen int `ind1d' = floor(`ind3d' / 100)

#delimit ;
local naicsdta
	"../industries/build/input/cwalk_naics2017_to_sector.dta";
#delimit cr

* 1-digit first
rename `ind1d' naics2017
#delimit ;
merge m:1 naics2017 using "`naicsdta'",
	keepusing(sector) keep(1 3 4) nogen update;
#delimit cr
drop naics2017

* 2-digit
rename `ind2d' naics2017
#delimit ;
merge m:1 naics2017 using "`naicsdta'",
	keepusing(sector) keep(1 3 4) nogen update;
#delimit cr
drop naics2017

* 3-digit
rename `ind3d' naics2017
#delimit ;
merge m:1 naics2017 using "`naicsdta'",
	keepusing(sector) keep(1 3 4) nogen update;
#delimit cr
drop naics2017