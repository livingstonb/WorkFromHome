program collapse2mat, rclass
	#delimit ;
	syntax anything(name=collapse_commands)
		[fweight pweight iweight]
		[, BY(varlist)]
		[, KEEPLABELS];
	#delimit cr

	preserve

	quietly drop if missing(`by')
	collapse `collapse_commands' [`weight'`exp'], by(`by') fast

	decode `by', gen(row_lbls)
	drop `by'
	order row_lbls

	capture matrix drop collapsed
	local matvars
	foreach var of varlist _all {
		if "`var'" != "row_lbls" {
			local matvars `matvars' `var'
		}
	}
	mkmat `matvars', matrix(collapsed) rownames(row_lbls)
	restore

	if "`keeplabels'" == "keeplabels" {
		local i = 0
		foreach var of varlist `matvars' {
			local nlab: variable label `var'
			
			if "`nlab'" == "" {
				local nlab `var'
			}

			if `i' == 0 {
				local newlabs `"`nlab'"'
			}
			else {
				local newlabs `"`newlabs'"' `"`nlab'"'
			}

			local i = `i' + 1
		}

		matrix colnames collapsed = `"`newlabs'"'
	}

	matrix list collapsed
	return matrix stats = collapsed
end	
