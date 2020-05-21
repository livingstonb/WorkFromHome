
* Prepare occupation crosswalks
use "../occupations/build/output/census2018_to_soc2010.dta", clear
gen yr_occ = 2018

rename census2018 occ

tempfile cwalk18
save `cwalk18'

use "../occupations/build/output/census2010_to_soc2010.dta", clear
gen yr_occ = 2010

rename census2010 occ

tempfile cwalk10
save `cwalk10'

* Read CPS data
clear
use "build/input/cps.dta"

* Clean
recode occ (0 = .)
recode ahrsworkt (999 = .)
recode earnweek (9999.99 = .)

* Merge occupation codes
gen yr_occ = 2010 if year < 2020
replace yr_occ = 2018 if year == 2020

merge m:1 occ yr_occ using `cwalk18', keep(1 3) nogen keepusing(soc3d2010)
merge m:1 occ yr_occ using `cwalk10', keep(1 3 4) nogen keepusing(soc3d2010) update
drop yr_occ

drop if missing(soc3d2010)

* Generate sample id
egen sample = group(year month)

* Compute average weekly earnings
bysort soc3d2010 sample: egen wgtsum = total(earnwt)
gen weights = earnwt / wgtsum if earnwt > 0

gen weighted = earnweek * weights
bysort soc3d2010 sample: egen mean_earnweek = total(weighted)

drop wgtsum weights weighted

* Compute average hours last week
bysort soc3d2010 sample: egen wgtsum = total(wtfinl)
gen weights = wtfinl / wgtsum if wtfinl > 0

gen weighted = ahrsworkt * weights
bysort soc3d2010 sample: egen mean_ahrsworkt = total(weighted)

drop wgtsum weights weighted

* Collapse
#delimit ;
collapse (firstnm) earnweek=mean_earnweek (firstnm) ahrsworkt=mean_ahrsworkt
	(sum) wtfinl (sum) earnwt, by(soc3d2010 year month);
#delimit cr

rename wtfinl weight_ahrsworkt
rename earnwt weight_earnweek

save "build/output/cps_output.dta", replace
