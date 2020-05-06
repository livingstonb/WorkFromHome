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
	
	if (`year' == 1998) {
		* local cw98 "../occupations/build/output/occsoc_soc3d2010.dta"
		
		* tempfile cwalkadj
		* preserve
		* use "`cw98'", clear
		

		* replace occ_code = occ_code + "0" if strlen(occ_code) == 5
		* replace occ_code = occ_code + "0000" if strlen(occ_code) == 2

		* drop occ_first2 occ_last4
	}
	else if (`year' == 1999) {
		
		drop if strpos(occ_code, "0000") > 0
		
		* First merge as many as possible with OES-SOC crosswalk
		local cw98 "../occupations/build/output/oes99_to_soc3d2010.dta"
		rename occ_code oes99code
		merge m:1 oes99code using "`cw98'", keepusing(soc3d2010) nogen
		rename oes99code occ_code
		
		local cw98 "../occupations/build/output/soc98_to_soc3d2010.dta"
		gen soc6d = subinstr(occ_code, "-", "", .)
		gen soc3d = substr(soc6d, 1, 3)
		gen soc4d = substr(soc6d, 1, 4)
		gen soc5d = substr(soc6d, 1, 5)

		forvalues d = 6(-1)3 {
			destring soc`d'd, force replace
			rename soc`d'd occsoc
			merge m:1 occsoc using "`cw98'", nogen keepusing(soc3d2010) keep(1 3 4) update
			drop occsoc
		}
		
		replace soc3d2010 = 119 if occ_code == "13-1061" & missing(soc3d2010)	
	}
	else if (`year' >= 2000) & (`year' < 2010) {
		rename occ_code soc2000
		#delimit ;
		merge m:1 soc2000 using 
			"../occupations/build/output/soc2000_to_soc3d2010.dta",
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
		
		gen soc5d2010 = substr(occ_code, 1, 6)
		replace soc5d2010 = subinstr(soc5d2010, "-", "", .)
		destring soc5d2010, replace force
		
		do "../occupations/build/output/soc5dlabels2010.do"
		label values soc5d2010 soc5d2010_lbl
		
		gen is_minor = (occ_group == "minor")
		gen is_broad = (occ_group == "broad")
				
		* For 3-digit aggregation -- some industries don't have minor summary groups
		bysort soc3d2010 naicscode: egen minor_present = max(is_minor)
		gen minor_level = is_minor | (is_broad & !minor_present)
		
		* For 5-digit aggregation
		rename is_broad broad_level

		drop is_minor minor_present
	}

	if (`year' >= 2018) {
		recode soc3d2010 (195 = 299)
	}

	do "../occupations/build/output/soc3dlabels2010.do"
	label values soc3d2010 soc3d2010_lbl
}
