use "$SIPPtemp/sipp_raw.dta", clear

// IDENTIFIERS
egen personid = group(ssuid pnum)
egen household = group(ssuid eresidenceid)
egen monthlyhousehold = group(monthcode household)

// CHOOSE SAMPLING UNIT
* Level, "hh" or "fam"
local sulevel "hh"

* 0 -> head only, 1 -> head & spouse, 2 -> head & spouse/partner
local nmain = 1

* Number of families from each HH to use, if sulevel = "fam"
local nfamilies = 1

// SETUP
discard
.su = .samplingunit.new

* Household vs. family level
if "`sulevel'" == "hh" {
	gen groupid = monthlyhousehold
	local nfamilies 1
}
else if "`sulevel'" == "fam" {
	egen groupid = group(monthlyhousehold rfamnum)
}

* Other declarations
.su.set_groupid groupid
.su.set_individualid personid
.su.set_panelid monthcode 1 12

* Idenfify group head
if "`sulevel'" == "hh" {
	gen grouphead = (rfamnum == 1) & (rfamref == pnum)
}
else if "`sulevel'" == "fam" {
	gen grouphead = inrange(rfamnum, 1, `nfamilies') & (rfamref == pnum)
}
.su.set_grouphead grouphead

* Other main members to include
forvalues i = 1/`nfamilies' {
	gen fam`i'head = (rfamref == pnum) & (rfamnum == `i')

	bysort fammonthly (fam`i'head): gen pnum_spouse = epnspouse[_N]
	gen fam`i'spouse = (pnum == pnum_spouse) & (rfamnum == `i')
	drop pnum_spouse

	bysort fammonthly (fam`i'head): gen pnum_partner = epncohab[_N]
	gen fam`i'partner = (pnum == pnum_partner) & (rfamnum == `i')
	drop pnum_partner

	drop fam`i'head pnum_spouse pnum_partner
}
egen famspouse = anymatch(fam*spouse), values(1)
egen fampartner = anymatch(fam*partner), values(1)

if `nmain' > 0 {
	.su.assign_members famspouse 1
}

if `nmain' > 1 {
	.su.assign_members fampartner 1
}
.su.clean_panel

* Check group sizes
.su.tab_groups

* ASSET SPLIT - GIVE TO FIRST FAMILY IN HOUSEHOLD
bysort sampleunit monthcode: egen nprimary = count(_marked) if (rfamref == 1)
gen su_share = 1 / nprimary if (_marked == 1) & (rfamref == 1)


compress
save "$SIPPtemp/sipp_temp.dta", replace
