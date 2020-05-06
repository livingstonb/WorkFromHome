program combine_5d_teleworkable
	syntax varname, [SOCVAL(integer -1) TELEVAL(integer -1) LABEL(string)]

	tempvar category subcategory

	gen `category' = (`varlist' == `socval')
	gen `subcategory' = inrange(`varlist', `socval'+1, `socval'+99)

	forvalues sector = 0/2 {
		quietly sum employment if `subcategory' & (sector == `sector')
		replace employment = `r(sum)' if `category' & (sector == `sector')
		quietly sum meanwage if `subcategory' & (sector == `sector') [iw=employment]
		replace meanwage = `r(mean)' if `category' & (sector == `sector')
	}

	replace teleworkable = `televal' if `category'
	label define `varlist'_lbl `socval' "`label'", modify
	
	* Critical workers
	quietly sum critical if `subcategory' [iw=employment]
	replace critical = `r(mean)' if `category'
	
	replace critical = 0 if (critical < 0.5)
	replace critical = 1 if (critical > 0.5)

	* Essential workers
	quietly sum essential if `subcategory' [iw=employment]
	replace essential = `r(mean)' if `category'

	drop if `subcategory'
end
