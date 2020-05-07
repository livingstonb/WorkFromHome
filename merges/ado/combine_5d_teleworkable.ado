/*
Aggregates a group of 6-digit occupation categories contained within the same
5-digit category to the 5-digit level.

--- Arguments ---
varname : The variable identifying the occupation code
socval : A 6-digit value ending in zero, identifying the 5-digit category
televal : The value for teleworkable for this occupation category
label : The value label to attach to this occupation group
*/

program combine_5d_teleworkable
	syntax varname, [SOCVAL(integer -1) TELEVAL(integer -1) LABEL(string)]

	tempvar category subcategory

	gen `category' = (`varlist' == `socval')
	gen `subcategory' = inrange(`varlist', `socval'+1, `socval'+99)

	* Aggregate employment and mean wage
	forvalues sector = 0/2 {
		quietly sum employment if `subcategory' & (sector == `sector')
		replace employment = `r(sum)' if `category' & (sector == `sector')
		quietly sum meanwage if `subcategory' & (sector == `sector') [iw=employment]
		replace meanwage = `r(mean)' if `category' & (sector == `sector')
	}

	replace teleworkable = `televal' if `category'
	label define `varlist'_lbl `socval' "`label'", modify
	
	* Critical workers, take weighted mean and round up or down
	quietly sum critical if `subcategory' [iw=employment]
	replace critical = `r(mean)' if `category'
	
	replace critical = 0 if (critical < 0.5)
	replace critical = 1 if (critical > 0.5)

	* Essential workers, take weighted mean to get essential share
	quietly sum essential if `subcategory' [iw=employment]
	replace essential = `r(mean)' if `category'

	drop if `subcategory'
end
