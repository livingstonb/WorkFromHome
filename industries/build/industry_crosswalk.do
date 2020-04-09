
* Prepare NAICS to sector data
clear
import delimited "build/input/naics_to_sector.csv", bindquotes(strict)
drop v1
drop if missing(sector)
label define sector_lbl 0 "C" 1 "S"
label values sector sector_lbl
save "build/output/naicsindex2017.dta", replace

* Prepare 2012 census codes
clear
import delimited "build/input/ind2012.csv", bindquotes(strict)
rename v1 ind2012
drop if _n == 1
replace ind2012 = strtrim(ind2012)
drop if strpos(ind2012, "-") > 1
destring ind2012, replace

tempfile ind2012tmp
save `ind2012tmp'

* Read census-sector correspondence
clear
local docpath "build/input/industryindex2017.xlsx"
import excel "`docpath'",  firstrow

rename census ind2017
drop description
label variable ind2017 "Industry, census code"

label variable sector "Sector, aggregate of industry"
label define sector_lbl 0 "C" 1 "S"
label values sector sector_lbl

* Save
save "build/output/industryindex2017.dta", replace

* Map from 2012 codes
use `ind2012tmp', clear
gen ind2017 = ind2012
recode ind2017 (1680 1690 = 1691) (3190 3290 = 3291) (4970 = 4971)
recode ind2017 (5380 = 5381) (5390 = 5391) (5590/5592 = 5593)
recode ind2017 (6990 = 6991) (7070 = 7071) (7170 7180 = 7181)
recode ind2017 (8190 = 8191) (8560 = 8563)
recode ind2017 (8880 8890 = 8891)

#delimit ;
merge m:m ind2017 using  "build/output/industryindex2017.dta",
	keepusing(sector) keep(match) nogen;
#delimit cr

drop ind2017
duplicates drop ind2012, force
order ind2012 sector
save "build/output/industryindex2012.dta", replace
