/* --- HEADER ---
This script aggregates to the annual frequency by summing earnings over
the year and using assets reported in the last month. Produces two datasets, one
at the individual level and one at the household level.
*/

`#PREREQ' use "build/temp/sipp_monthly2.dta", clear

* Earnings
bysort personid swave: egen earnings = total(grossearn)
label variable earnings "earnings"

* WFH
by personid swave: egen wfh = max(workfromhome)
by personid swave: egen mwfh = max(wfh_mainocc)
drop workfromhome wfh_mainocc

replace wfh = 100 * wfh
replace mwfh = 100 * mwfh
rename wfh workfromhome
rename mwfh mworkfromhome
label variable workfromhome " % Who worked from home at least one day of the week"
label variable mworkfromhome " % Who worked from home at least one day of the week in main occ"

// Person-level
preserve

bysort personid swave: gen nmonths = _N
keep if (monthcode == 12) & (nmonths == 12)
drop nmonths

`#TARGET' save "build/output/annual_person.dta", replace
restore



// Family-level
preserve
egen famgroup = group(ssuid eresidenceid swave rfamnum monthcode)

* Drop individuals not showing up in all twelve months
bysort personid swave: gen nmonths = _N
drop if (nmonths < 12)

* Identify stable families

* Drop individuals who were a family reference member, but not for all 12 months
gen is_famref = (pnum == rfamref)
bysort personid swave: egen famref = total(is_famref)
drop if inrange(famref, 1, 11)

* Drop family reference members with unstable spouse-present status
gen spouse_present = (ems == 1) if is_famref

#delimit ;
bysort personid swave (monthcode):
	gen stable_famref = (spouse_present[1] == spouse_present[_N]) if is_famref;
#delimit cr
drop if !stable_famref

* Identify families by personid of reference member
bysort famgroup: gen tmp_famid = personid if is_famref
by famgroup: egen famid = max(tmp_famid)
drop if missing(famid)
drop famgroup

* Identify stable household members
bysort personid swave (famid): gen stable_member = (famid[1] == famid[_N])
drop if !stable_member
drop stable_member

* Keep last month only
keep if monthcode == 12
drop monthcode

* Identify main earner (member who reported the highest annual earnings)
bysort famid swave: egen max_earn = max(earnings)
gen main_earner = (max_earn == earnings) if (earnings > 0)
drop max_earn

* Drop very small number of families where married couples have copied earnings
by famid swave: egen num_main_earners = total(main_earner)
drop if (num_main_earners > 1)
drop num_main_earners

* Assign occupation of main earner to family
local digits 3 5
foreach d of local digits {
	bysort famid swave: gen tmp1_occ`d'd2010 = occ`d'd2010 if main_earner
	by famid swave: egen tmp2_occ`d'd2010 = max(tmp1_occ`d'd2010)
	replace occ`d'd2010 = tmp2_occ`d'd2010
	drop tmp*_occ`d'd2010
}

* Assign sector of main earner to family
bysort famid swave: gen tmp1_sector = sector if main_earner
by famid swave: egen tmp2_sector = max(tmp1_sector)
replace sector = tmp2_sector
drop tmp*_sector

* Collapse to family level
