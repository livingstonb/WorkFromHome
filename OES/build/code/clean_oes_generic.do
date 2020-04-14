/* --- HEADER ---
Cleans one year of OES data.
*/

args year aggregate_occs

capture rename o_group occ_group
capture rename group occ_group
capture rename GROUP occ_group
capture rename naics_title indtitle

foreach var of varlist _all {
	local newname = lower("`var'")
	capture rename `var' `newname'
}
capture rename naics naicscode

local stringvars occ_code tot_emp a_mean occ_group
foreach var of local stringvars  {
	capture replace `var' = strtrim(`var')
}

local stringvars tot_emp a_mean a_median pct_total
foreach var of local stringvars {
	capture destring `var', force replace
}

if "`aggregate_occs'" == "1" {
	capture drop if inlist(occ_group, "total", "major")
	if (`year' >= 2000) & (`year' < 2010) {
		rename occ_code soc2000
		#delimit ;
		merge m:1 soc2000 using 
			"../occupations/build/output/soc3d_2000_to_2010_crosswalk.dta",
			keepusing(soc3d2010) nogen keep(1 3);
		#delimit cr
	}
	else if (`year' < 2012) {
		gen soc3d2010 = substr(occ_code, 1, 4)
		replace soc3d2010 = subinstr(soc3d2010, "-", "", .)
		destring soc3d2010, replace force
	}
	else {
		drop if (occ_group == "detailed")
		gen soc3d2010 = substr(occ_code, 1, 4)
		replace soc3d2010 = subinstr(soc3d2010, "-", "", .)
		destring soc3d2010, replace force
		
		gen occ_broad = occ_code if occ_group == "broad"
		
		gen minors = (occ_group == "minor")
		bysort soc3d2010: egen minor_present = max(minors)
		
		drop if (occ_group == "broad") & minor_present		
	}

	if (`year' >= 2018) {
		recode soc3d2010 (195 = 299)
	}

	do "../occupations/build/output/occ3labels2010.do"
	label values soc3d2010 soc3d2010_lbl
}