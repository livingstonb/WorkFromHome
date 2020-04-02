use "$SIPPtemp/sipp_monthly.dta", clear

// IDENTIFIERS
egen household = group(ssuid eresidenceid)
egen monthlyhh = group(monthcode household)

// HOUSEHOLD-LEVEL
* Find group head
gen hhhead = (rfamnum == 1) & (rfamref == pnum)

* Find spouse
bysort monthlyhh (hhhead): gen pnum_spouse = epnspous_ehc[_N]
gen spouse = (pnum == pnum_spouse) & (rfamnum == 1)

* All others
gen others = (pnum != pnum_spouse) & (hhhead != 1)

* Find children
bysort monthlyhh (hhhead): gen pnum_head = rfamref[_N]
gen child = (rpnpar1_ehc == pnum_head) | (rpnpar2_ehc == pnum_head) & (rfamnum == 1)

* Find other family heads
gen othfamheads = (rfamnum > 1)

* Find anyone who has never been hh head or hh head spouse
bysort personid: egen oth1ind = max(hhhead)
bysort personid: egen oth2ind = max(spouse)
gen otherind = (oth1ind == 0) & (oth2ind == 0)

discard
.su = .samplingunit.new
.su.set_groupid monthlyhh
.su.set_individualid personid
.su.set_panelid monthcode, range(1 12)
.su.set_grouphead hhhead
.su.create
.su.assign_member spouse, memberid(2) required
.su.new_groups otherind, memberid(5)
// .su.new_groups child, memberid(3)
// .su.new_groups othfamheads, memberid(4)
// .su.new_groups _others, memberid(5)
.su.create_ownership_weights aweights, memberids(1, 2) replace

* Check group sizes
.su.tab_groups

label variable _sampleunit "Sampling unit, household"

compress
save "$SIPPtemp/sipp_monthly_with_su.dta", replace
