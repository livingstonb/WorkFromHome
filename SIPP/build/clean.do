use "$SIPPtemp/sipp_raw.dta", clear

* // IDENTIFIERS
egen personid = group(ssuid pnum)
egen household = group(ssuid eresidenceid)
egen hhmonthly = group(ssuid monthcode eresidenceid)
egen fammonthly = group(ssuid monthcode eresidenceid rfamnum)

*** EACH FAMILY MEMBER CAN BE TIED TO REF BY RELATIONSHIP TO... VARIABLE

// BY HOUSEHOLD
gen hhhead = (rfamnum == 1) & (rfamref == pnum)

bysort hhmonthly (hhhead): gen pnum_spouse = epnspouse[_N]
gen hhspouse = (pnum == pnum_spouse)

discard
.su = .samplingunit.new
.su.set_groupid hhmonthly
.su.set_individualid personid
.su.set_panelid monthcode 1 12
.su.set_grouphead hhhead
.su.assign_members hhspouse
.su.check_panel

capture drop sampleN
bysort sampleunit: gen sampleN = _N
tab sampleN if !missing(sampleunit)

// BY FAMILY
gen famhead = (rfamref == pnum) & inrange(rfamnum, 1, 4)

bysort fammonthly (famhead): gen pnum_spouse = epnspouse[_N]
gen famspouse = (pnum == pnum_spouse)

discard
.su = .samplingunit.new
.su.set_groupid fammonthly
.su.set_individualid personid
.su.set_panelid monthcode 1 12
.su.set_grouphead famhead
.su.assign_members famspouse
.su.check_panel

capture drop sampleN
bysort sampleunit: gen sampleN = _N
tab sampleN if !missing(sampleunit)



// ADO FILE
egen famid = group(ssuid eresidenceid rfamnum)
bysort famid monthcode: gen tmprefid = personid if (rfamref == pnum)
bysort famid monthcode: egen refid = max(tmprefid)

* Monthly family identifier must be equal across members
* Family must have the same reference member throughout time
.su = .sampleunit.new
.su.set_groupid famid
.su.set_panelid monthcode

.su.create_su
.su.imposeconstant rfamref

bysort_distribute spouseid = epnspouse if (pnum == rfamref), over(`.su.sampleunit')

.su.generate epnspouse 

sampleunit create, su(family) panelid(monthcode) groupid(famid)
sampleunit head, su(family) panelid(monthcode) head(rfamref)

generate_within family monthcode head, value(epnspouse) gen(spouse)



sampleunit gen, su(family) panelid(monthcode) headvar(rfamref) headvar(epnspouse)



// FAMILIES

* Unique family id
egen ftmp = group(ssuid eresidenceid rfamnum) if monthcode == 1
bysort personid (monthcode): gen family = ftmp[1]
drop ftmp

* Unique person id of HH reference
gen famhead = personid if (rfamref == pnum)
bysort family monthcode: egen numheads = count(famhead)

* If numheads == 0, original head of a family left
* If numheads > 1, someone in original family started new family
bysort family: egen nlow = min(numheads)
bysort family: egen nhigh = max(numheads)
replace family = . if (nlow < 1) | (nhigh > 1)
replace famhead = . if (nlow < 1) | (nhigh > 1)
drop numheads

* Update famhead
bysort family monthcode: egen tmp_famhead = max(famhead)
drop famhead
rename tmp_famhead famhead

* Check for constant head
bysort family (famhead): gen consthead = (famhead[_N] == famhead[1])
replace family = . if (consthead == 0)
replace famhead = . if (consthead == 0)
drop consthead

* Check for stable marriage
gen tmp_famspouse = epnspouse if (rfamref == pnum)
bysort family monthcode: egen famspouse = max(tmp_famspouse)
bysort family (famspouse): gen constspouse = (famspouse[_N] == famspouse[1])
replace family = . if (constspouse == 0)
replace famhead = . if (constspouse == 0)
replace famspouse = . if (constspouse == 0)
drop tmp_famspouse  constspouse

// FAMILY HEADS: SINGLES AND COUPLES
gen coupleid = family if (personid == famhead) | (pnum == famspouse)

// FAMILY HEADS, COMBINING COUPLES IN ONE HOUSEHOLDS
bysort household monthcode: egen hhcoupleid = max(coupleid)if !missing(coupleid)






compress
save "$SIPPtemp/sipp_temp.dta", replace
