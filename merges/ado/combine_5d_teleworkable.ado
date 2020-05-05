program combine_5d_teleworkable
	syntax varname, [SOCVAL(integer -1) TELEVAL(integer -1) LABEL(string)]

	tempvar category subcategory

	gen `category' = (`varlist' == `socval')
	gen `subcategory' = inrange(`varlist', `socval'+1, `socval'+99)

	forvalues sector = 0/2 {
		quietly sum employment if `subcategory' & (sector == `sector')
		replace employment = `r(sum)' if `category' & (sector == `sector')
		quietly sum meanwage [iw=employment] if `subcategory' & (sector == `sector')
		replace meanwage = `r(mean)' if `category' & (sector == `sector')
	}

	replace teleworkable = `televal' if `category'
	label define `varlist'_lbl `socval' "`label'", modify

	drop if `subcategory'
end
