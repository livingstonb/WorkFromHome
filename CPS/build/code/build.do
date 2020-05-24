
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
recode wksworkorg (0 98 = .)
recode uhrsworkt (997 999 = .)

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
bysort soc3d2010 sample: egen wgt_earnweek = total(earnwt) if (earnweek > 0) & !missing(earnweek), missing
gen weights = earnwt / wgt_earnweek if earnwt > 0

gen weighted = earnweek * weights
bysort soc3d2010 sample: egen mean_earnweek = total(weighted), missing

drop weights weighted

* Weekly earnings, n
bysort soc3d2010 sample: egen n_earnweek = count(earnweek) if (earnweek > 0) & (earnwt > 0)

* Compute average hours last week
bysort soc3d2010 sample: egen wgt_ahrsworkt = total(wtfinl) if !missing(ahrsworkt), missing
gen weights = wtfinl / wgt_ahrsworkt if wtfinl > 0

gen weighted = ahrsworkt * weights
bysort soc3d2010 sample: egen mean_ahrsworkt = total(weighted), missing

drop weights weighted

* Average hours, n
bysort soc3d2010: egen n_ahrsworkt = count(ahrsworkt)

* Share employed
gen employed = inlist(empstat, 10, 12)
bysort soc3d2010 sample: egen wgt_employed = total(wtfinl) if !missing(employed), missing
gen weights = wtfinl / wgt_employed if wtfinl > 0

gen weighted = employed * weights
bysort soc3d2010 sample: egen share_employed = total(weighted), missing

drop weights weighted

* Weeks worked
bysort soc3d2010 sample: egen wgt_wksworkorg = total(earnwt) if !missing(wksworkorg), missing
gen weights = earnwt / wgt_wksworkorg if earnwt > 0

gen weighted = wksworkorg * weights
bysort soc3d2010 sample: egen mean_wksworkorg = total(weighted), missing

drop weights weighted

* Usual hours worked
bysort soc3d2010 sample: egen wgt_uhrsworkt = total(wtfinl) if !missing(uhrsworkt), missing
gen weights = wtfinl / wgt_uhrsworkt if wtfinl > 0

gen weighted = uhrsworkt * weights
bysort soc3d2010 sample: egen mean_uhrsworkt = total(weighted), missing

drop weights weighted

* Collapse
#delimit ;
collapse (firstnm) earnweek=mean_earnweek (firstnm) ahrsworkt=mean_ahrsworkt
	(firstnm) wgt_earnweek (firstnm) wgt_ahrsworkt (firstnm) soc2d2010
	(firstnm) employed=share_employed (firstnm) wgt_employed
	(firstnm) wksworkorg=mean_wksworkorg (firstnm) wgt_wksworkorg
	(firstnm) uhrsworkt=mean_uhrsworkt (firstnm) wgt_uhrsworkt
	(firstnm) n_ahrsworkt (firstnm) n_earnweek, by(soc3d2010 year month);
#delimit cr

do "../occupations/build/output/soc2dlabels2010.do"
label values soc2d2010 soc2d2010_lbl

#delimit ;
local vars year month soc2d2010 soc3d2010 earnweek wgt_earnweek n_earnweek
	ahrsworkt wgt_ahrsworkt n_ahrsworkt employed wgt_employed
	wksworkorg wgt_wksworkorg uhrsworkt wgt_uhrsworkt;
#delimit cr

sort year month soc2d2010 soc3d2010
order `vars'

label variable year "Survey year"
label variable month "Survey month"
label variable soc2d2010 "SOC 2010 major group"
label variable soc3d2010 "SOC 2010 minor group"
label variable earnweek "Mean of EARNWEEK for EARNWEEK > 0, in minor group"
label variable ahrsworkt "Mean of AHRSWORKT, in minor group"
label variable wgt_earnweek "Sum of weights for earnweek, in minor group"
label variable wgt_ahrsworkt "Sum of weights for ahrsworkt, in minor group"
label variable n_earnweek "Unweighted number of obs of EARNWEEK for EARNWEEK > 0, in minor group"
label variable n_ahrsworkt "Unweighted number of obs of AHRSWORKT, in minor group"
label variable employed "Share employed, in minor group"
label variable wgt_employed "Sum of weights for employed, in minor group"
label variable wksworkorg "Mean of WKSWORKORG, in minor group"
label variable wgt_wksworkorg "Sum of weights for wksworkorg, in minor group"
label variable uhrsworkt "Mean of UHRSWORKT, in minor group"
label variable wgt_uhrsworkt "Sum of weights for uhrsworkt, in minor group"

save "build/output/cps_output.dta", replace
