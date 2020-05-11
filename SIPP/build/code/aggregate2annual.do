/* --- HEADER ---
This script aggregates to the annual frequency by summing earnings over
the year and using assets reported in the last month. Argument passed is the
desired sample unit, either person, hh, or fam.
*/

`#PREREQ' use "build/temp/sipp_monthly2.dta", clear

args sunit

egen person_wave = group(personid swave)
local cash_multiplier = 1.05

* Drop individuals not showing up in all twelve months
bysort personid swave: gen nmonths = _N
drop if (nmonths < 12)
drop nmonths

// Person-level
if "`sunit'" == "person" {
	gen sampleid = person_wave
	gen swgts = wpfinwgt

	* Keep last month only
	keep if monthcode == 12
	drop monthcode
}

// Household- or family-level
if "`sunit'" == "hh" {
	egen monthgroup = group(ssuid eresidenceid swave monthcode)
	gen is_ref = (pnum == rfamref) & (rfamnum == 1)
}
else if "`sunit'" == "fam" {
	egen monthgroup = group(ssuid eresidenceid swave rfamnum monthcode)
	gen is_ref = (pnum == rfamref)
}

if ("`sunit'" == "hh") | ("`sunit'" == "fam") {
	* Drop individuals who were a reference member, but not for all 12 months
	bysort personid swave: egen months_ref = total(is_ref)
	drop if inrange(months_ref, 1, 11)
	drop months_ref

	* Drop reference members with unstable spouse-present status
	bysort personid swave (epnspous_ehc): gen constmarried = (epnspous_ehc[1] == epnspous_ehc[_N])
	drop if is_ref & !constmarried
	
	* Create unit id based on personid of reference member
	bysort monthgroup: gen tmp_sampleid = person_wave if is_ref
	by monthgroup: egen sampleid = max(tmp_sampleid)
	drop if missing(sampleid)
	drop tmp_sampleid monthgroup
	
	* Identify stable members
	bysort personid swave (sampleid): gen stable_member = (sampleid[1] == sampleid[_N])
	drop if !stable_member
	drop stable_member
	
	* Keep last month only
	keep if monthcode == 12
	drop monthcode
	
	* Drop families if spouse has been dropped from the sample
	bysort sampleid: gen tmp_famnumref = rfamnum if is_ref
	bysort sampleid: gen tmp_spousepnum = epnspous_ehc if is_ref
	by sampleid: egen famnumref = max(tmp_famnumref)
	by sampleid: egen spousepnum = max(tmp_spousepnum)

	gen is_spouse = (pnum == spousepnum) & (rfamnum == famnumref) if !missing(spousepnum)
	by sampleid: egen spouse_present = max(is_spouse)
	keep if spouse_present | missing(spousepnum)
	drop *famnumref *spousepnum spouse_present
	
	* Create weights
	if "`sunit'" == "hh" {
		gen tmp_swgts = wpfinwgt if inlist(erelrpe, 1, 2)
	}
	else {
		gen tmp_swgts = wpfinwgt if is_ref
	}
	bysort sampleid: egen swgts = max(tmp_swgts)
	drop tmp_swgts
	
	* Identify main earner (member who reported the highest annual earnings)
	bysort sampleid: egen max_earn = max(earnings)
	gen main_earner = (max_earn == earnings) if (earnings > 0)
	drop max_earn

	* Drop very small number of cases where married couples have copied earnings
	by sampleid: egen num_main_earners = total(main_earner)
	drop if (num_main_earners > 1)

	* Designate reference member as main earner if all members unemployed
	replace main_earner = 1 if is_ref & (num_main_earners == 0)
	
	* Collapse over sample unit members
	foreach var of varlist val_* liab_ccdebt earnings {
		bysort sampleid: egen tmp_var = total(`var'), missing
		replace `var' = tmp_var
		drop tmp_var
	}
	keep if main_earner
	drop is_ref main_earner num_main_earners
}

// WEALTH VARIABLES
* Liquid assets
egen pdeposits = rowtotal(val_sav val_ichk val_chk val_mm)
label variable pdeposits "deposits"

egen pbonds = rowtotal(val_govs val_mcbd)
label variable pbonds "government and corporate bonds"

egen pliqequity = rowtotal(val_st val_mf)
label variable pliqequity "stocks and mutual funds"

egen liquid_nocash = rowtotal(pdeposits pbonds pliqequity)
label variable liquid_nocash "liquid assets, assuming no cash"

gen liquid_wcash = liquid_nocash * `cash_multiplier'
label variable liquid_wcash "liquid assets, with assumed cash"

* Liquid liabilities
gen ccdebt = liab_ccdebt
label variable ccdebt "credit card debt"

* Illiquid
gen phomeequity = val_homeequity
label variable phomeequity "home equity"

egen pretirement = rowtotal(val_ira_keoh val_401k val_ann val_trusts)
label variable pretirement "retirement accounts"

egen netilliquid = rowtotal(phomeequity pretirement val_cd val_life)
label variable netilliquid "net illiquid assets"

// OTHER VARIABLES
gen netliquid = liquid_wcash - ccdebt
label variable netliquid "net liquid assets"

gen netliq_earnings_ratio = netliquid / earnings if (earnings > 1000)
label variable netliq_earnings_ratio "net liquid assets to earnings ratio for earnings > 1000"

tempvar earnwk
gen `earnwk' = earnings / 52

gen nla_lt_biweeklyearn = (netliquid < (2 * `earnwk'))
label variable nla_lt_biweeklyearn "Share with net liquid assets < 2 weeks earnings"

gen nla_lt_monthlyearn = (netliquid < (4 * `earnwk'))
label variable nla_lt_monthlyearn "Share with net liquid assets < 4 weeks earnings"

gen nla_lt_annearn = (netliquid < earnings)
label variable nla_lt_annearn "Share with net liquid assets < annual earnings"

gen whtm_biweeklyearn = (netliquid < (2 * `earnwk')) * (netilliquid >= 5000)
label variable whtm_biweeklyearn "Share WHtM (NLIQ < 2 wks earnings and NILLIQ >= $5000)"

gen whtm_monthlyearn = (netliquid < (4 * `earnwk')) * (netilliquid >= 5000)
label variable whtm_monthlyearn "Share WHtM (NLIQ < 4 wks earnings and NILLIQ >= $5000)"

gen whtm_annearn = (netliquid < earnings) * (netilliquid >= 5000)
label variable whtm_annearn "Share WHtM (NLIQ < annual earnings and NILLIQ >= $5000)"

gen phtm_biweeklyearn = (nla_lt_biweeklyearn == 1) * (whtm_biweeklyearn == 0)
replace phtm_biweeklyearn = . if missing(nla_lt_biweeklyearn, whtm_biweeklyearn)
label variable phtm_biweeklyearn "Share PHtM (NLIQ < 2 wks earnings and NILLIQ < $5000)"

gen phtm_monthlyearn = (nla_lt_monthlyearn == 1) * (whtm_monthlyearn == 0)
replace phtm_monthlyearn = . if missing(nla_lt_monthlyearn, whtm_monthlyearn)
label variable phtm_monthlyearn "Share PHtM (NLIQ < 4 wks earnings and NILLIQ < $5000)"

gen phtm_annearn = (nla_lt_annearn == 1) * (whtm_annearn == 0)
replace phtm_annearn = . if missing(nla_lt_annearn, whtm_annearn)
label variable phtm_annearn "Share PHtM (NLIQ < annual earnings and NILLIQ < $5000)"

#delimit ;
gen htm_biweeklyearn = whtm_biweeklyearn | phtm_biweeklyearn
	& !missing(whtm_biweeklyearn, phtm_biweeklyearn);
gen htm_monthlyearn = whtm_monthlyearn | phtm_monthlyearn
	& !missing(whtm_monthlyearn, phtm_monthlyearn);
gen htm_annearn = whtm_annearn | phtm_annearn
	& !missing(whtm_annearn, phtm_annearn);
#delimit cr

label variable htm_biweeklyearn "Share HTM (NLIQ < 2 wks earnings)"
label variable htm_monthlyearn "Share HTM (NLIQ < 4 wks earnings)"
label variable htm_annearn "Share HTM (NLIQ < annual earnings)"

foreach x of numlist 500 1000 2000 {
	gen nla_lt_`x'_nia_any = (netliquid < `x') if !missing(netliquid)
	label variable nla_lt_`x'_nia_any "Share with NLIQ < $`x'"
foreach y of numlist 1000 5000 {
	gen nla_lt_`x'_nia_gt_`y' = (netliquid < `x') * (netilliquid > `y')
	replace nla_lt_`x'_nia_gt_`y' = . if missing(netliquid, netilliquid)
	label variable nla_lt_`x'_nia_gt_`y' "Share with NLIQ < $`x' and NILLIQ > $`y'"
}
}

drop `earnwk'

drop person_wave
`#TARGET' save "build/output/annual_`sunit'.dta", replace
