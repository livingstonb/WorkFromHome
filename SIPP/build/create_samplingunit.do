// NOTE: FIRST RUN "do macros.do" IN THE MAIN DIRECTORY

/* Dataset: SIPP */
/* This script takes the monthly SIPP data after new variables have been created,
and creates a sampling unit variable. Weights are created that apportion
household-level assets between the one or two primary household members of each
household. Observations not present in all twelve months are coded as missing in
the sampling unit variable. When the household heads (either one or two) are not
both present in all twelve months and have a stable relationship status (either
not married the entire time, or married to the same other household head), both
household heads are coded as missing in the sampling unit variable. */

/* Must first set the global macro: wave. */

use "$SIPPtemp/sipp_monthly_w${wave}.dta", clear

// IDENTIFIERS
egen household = group(ssuid eresidenceid)
egen monthlyhh = group(monthcode household)

// HOUSEHOLD-LEVEL
* Find group head
gen hhhead = (rfamnum == 1) & (rfamref == pnum)

* Find spouse
bysort monthlyhh (hhhead): gen pnum_spouse = epnspous_ehc[_N]
gen spouse = (pnum == pnum_spouse) & (rfamnum == 1)
drop pnum_spouse

* Find other family heads
gen othfamheads = (rfamnum > 1)

* Find anyone who has never been hh head or hh head spouse
bysort personid: egen oth1ind = max(hhhead)
bysort personid: egen oth2ind = max(spouse)
gen otherind = (oth1ind == 0) & (oth2ind == 0)
drop oth1ind oth2ind

* Use samplingunit class to create sampling unit variable and
* weights for household-level assets
discard
.su = .samplingunit.new
.su.set_groupid monthlyhh
.su.set_individualid personid
.su.set_panelid monthcode, range(1 12)
.su.set_grouphead hhhead
.su.create
.su.assign_member spouse, memberid(2) required
.su.new_groups otherind, memberid(5)
.su.create_ownership_weights aweights, memberids(1, 2) replace

* Check group sizes
.su.tab_groups

label variable _sampleunit "Sampling unit, household"

compress
save "$SIPPtemp/sipp_monthly_with_su_w${wave}.dta", replace
