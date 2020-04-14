/* --- HEADER ---
This do-file cleans the OES datasets and aggreagates to the 3-digit occupation level.
*/

clear

* Prepare blank occupation categories
`#PREREQ' use "../occupations/build/output/occindex2010.dta"
duplicates drop soc3d2010, force
keep soc3d2010

tempfile dups
save `dups'

clear
tempfile out
save `out', emptyok
forvalues year = 2000/2019 {
	if (`year' == 2002) {
		local digit = 4
	}
	else if (`year' == 2003) {
		local digit = 3
	}
	else {
		local digit = 2
	}

	import excel "build/input/nat`digit'd`year'", clear firstrow
	
	// DO SOME CLEANING
	capture rename o_group occ_group
	capture rename group occ_group
	capture rename GROUP occ_group
	
	local caps OCC_GROUP TOT_EMP OCC_CODE A_MEAN
	foreach var of local caps {
		local newname = lower("`var'")
		capture rename `var' `newname'
	}
	
	local stringvars occ_code tot_emp a_mean occ_group
	foreach var of local stringvars  {
		capture replace `var' = strtrim(`var')
	}
	destring a_mean, force replace
	destring tot_emp, force replace

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
	
	* Collapse
	gen employment = 1
	#delimit ;
	collapse (mean) meanwage=a_mean (sum) employment [iw=tot_emp],
		by(soc3d2010);
	#delimit cr
	drop if missing(soc3d2010)
	
	* Add blanks if necessary
	append using `dups', gen(dup)
	bysort soc3d2010: egen n_nonmissing = count(employment)
	drop if dup & (n_nonmissing > 0)
	drop n_nonmissing dup
	
	`#PREREQ' do "../occupations/build/output/occ3labels2010.do"
	label values soc3d2010 soc3d2010_lbl
	
	gen year = `year'
	
	* Update tempfile
	append using `out'
	save `out', replace
}

sort soc3d2010 year
order soc3d2010 year
`#TARGET' save "stats/output/occupation_level_employment.dta", replace
