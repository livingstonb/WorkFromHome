/* --- HEADER ---
Aggregates OES data to the level of 3-digit occupation level.

#PREREQ "../occupations/build/output/soc3d_2000_to_2010_crosswalk.dta"
#PREREQ "../occupations/build/output/occ3labels2010.do"
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
	
	* Clean
	`#PREREQ' do "build/code/clean_oes_generic.do" `year'
	
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
	
	gen year = `year'
	
	* Update tempfile
	append using `out'
	save `out', replace
}

sort soc3d2010 year
order soc3d2010 year
`#TARGET' save "stats/output/occupation_level_employment.dta", replace
