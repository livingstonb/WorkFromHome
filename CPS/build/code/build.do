
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
keep if inrange(age, 16, 65)
drop age

* Clean
recode occ (0 = .)
recode ahrsworkt (999 = .)
recode earnweek (9999.99 = .)

* Merge occupation codes
gen yr_occ = 2010 if year < 2020
replace yr_occ = 2018 if year == 2020

merge m:1 occ yr_occ using `cwalk18', keep(1 3) nogen keepusing(soc3d2010 soc2d2010)
merge m:1 occ yr_occ using `cwalk10', keep(1 3 4) nogen keepusing(soc3d2010 soc2d2010) update
drop yr_occ

drop if missing(soc3d2010)

* Generate sample id
egen sample = group(year month)

* Compute average weekly earnings
bysort soc3d2010 sample: egen wgtsum = total(earnwt) if (earnweek > 0) & !missing(earnweek)
gen weights = earnwt / wgtsum if earnwt > 0

gen weighted = earnweek * weights
bysort soc3d2010 sample: egen mean_earnweek = total(weighted), missing

drop wgtsum weights weighted

* Weekly earnings, n
bysort soc3d2010 sample: egen n_earnweek = count(earnweek) if (earnweek > 0) & (earnwt > 0)

* Compute average hours last week
bysort soc3d2010 sample: egen wgtsum = total(wtfinl) if !missing(ahrsworkt)
gen weights = wtfinl / wgtsum if wtfinl > 0

gen weighted = ahrsworkt * weights
bysort soc3d2010 sample: egen mean_ahrsworkt = total(weighted), missing

drop wgtsum weights weighted

* Average hours, n
bysort soc3d2010: egen n_ahrsworkt = count(ahrsworkt)

* Share employed
gen employed = inlist(empstat, 10, 12)
bysort soc3d2010 sample: egen wgtsum = total(wtfinl)
gen weights = wtfinl / wgtsum if wtfinl > 0

gen weighted = employed * weights
bysort soc3d2010 sample: egen share_employed = total(weighted)

drop wgtsum weights weighted

* Collapse
#delimit ;
collapse (firstnm) earnweek=mean_earnweek (firstnm) ahrsworkt=mean_ahrsworkt
	(sum) wtfinl (sum) earnwt (firstnm) soc2d2010 (firstnm) share_employed
	(firstnm) n_ahrsworkt (firstnm) n_earnweek, by(soc3d2010 year month);
#delimit cr

do "../occupations/build/output/soc2dlabels2010.do"
label values soc2d2010 soc2d2010_lbl

rename wtfinl wgt_ahrsworkt
rename earnwt wgt_earnweek
rename share_employed employed

#delimit ;
local vars year month soc2d2010 soc3d2010 earnweek wgt_earnweek n_earnweek
	ahrsworkt wgt_ahrsworkt n_ahrsworkt employed;
#delimit cr

sort `vars'
order `vars'

label variable year "Survey year"
label variable month "Survey month"
label variable soc2d2010 "SOC 2010 major group"
label variable soc3d2010 "SOC 2010 minor group"
label variable earnweek "Mean of EARNWEEK for EARNWEEK > 0, in minor group"
label variable ahrsworkt "Mean of AHRSWORKT, in minor group"
label variable wgt_earnweek "Sum of weights EARNWT for EARNWEEK > 0, in minor group"
label variable wgt_ahrsworkt "Sum of weights WTFINL for AHRSWORKT, in minor group"
label variable n_earnweek "Unweighted number of obs of EARNWEEK for EARNWEEK > 0, in minor group"
label variable n_ahrsworkt "Unweighted number of obs of AHRSWORKT, in minor group"
label variable employed "Share employed, in minor group"

save "build/output/cps_output.dta", replace
