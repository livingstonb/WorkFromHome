program collapse2excel
	#delimit ;
	syntax anything(name=collapse_commands)
		[fweight pweight iweight] [if] using/
		[, BY(varlist)]
		[, TITLE(string)]
		[, MODIFY]
		[, SHEET(string)]
		[, CW];
	#delimit cr

	preserve

	quietly drop if missing(`by')
	marksample touse
	collapse `collapse_commands' [`weight'`exp'] if `touse', by(`by') fast `cw'
	
	tempfile collapsetmp
	save `collapsetmp'
	
	ds
	local cvars `r(varlist)'

	restore
	preserve

	* Restore original labels
	local i = 0
	foreach var of local cvars {
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
		local ++i
	}
	
	use `collapsetmp', clear
	
	local i = 1
	foreach var of local cvars {
		local vlab: word `i' of `"`newlabs'"'
		label variable `var' `"`vlab'"'
		
		local ++i
	}


	// ADD TO SPREADSHEET
	if "`modify'" == "" {
		#delimit ;
		export excel using "`using'", keepcellfmt `replace'
			cell(A3) firstrow(varlabels) sheet("`sheet'", replace);
		#delimit cr
		
		* Add title
		putexcel set "`using'", modify sheet("`sheet'")
		putexcel A1=("`title'")
	}
	else {
		#delimit ;
		export excel using "`using'", keepcellfmt
			cell(A3) firstrow(varlabels) sheet("`sheet'", modify);
		#delimit cr
	}
	
	restore
end	
