/*
Maps 2012 Census industry categories to sectors C and S.
*/

clear

* Read all 2012 codes
local ind12codes "build/input/ind2012codes.csv"
import delimited "`ind12codes'", bindquotes(strict) varname(1)

replace ind2012 = strtrim(ind2012)
destring ind2012, force replace

* Map to 2017 codes
gen ind2017 = ind2012
recode ind2017 (1680 1690 = 1691) (3190 3290 = 3291) (4970 = 4971)
recode ind2017 (5380 = 5381) (5390 = 5391) (5590/5592 = 5593)
recode ind2017 (6990 = 6991) (7070 = 7071) (7170 7180 = 7181)
recode ind2017 (8190 = 8191) (8560 = 8563)
recode ind2017 (8880 8890 = 8891)

#delimit ;
merge m:m ind2017 using "build/input/census2017_to_sector.dta",
	keepusing(sector) keep(match) nogen;
#delimit cr

drop ind2017
duplicates drop ind2012, force
order ind2012 sector

save "build/output/census2012_to_sector.dta", replace
