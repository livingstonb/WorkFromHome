program collapsecustom
	#delimit ;
	syntax anything(name=variables)
		[fweight pweight iweight] [if] using/
		[, BY(string)]
		[, MODIFY] [, SHEET(string)]
		[, CW];
	#delimit cr

	preserve
	
	tokenize `variables'
	local collapse_commands
	while "`1'" != "" {
		local collapse_commands `collapse_commands' ``1'.collapse'
		macro shift
	}
	
	tokenize `by'
	local byvars
	local n_byvars = 0
	while "`1'" != "" {
		local byvars `byvars' ``1'.varname'
		`1'.dropmissing
		macro shift
		local ++n_byvars
	}

	marksample touse
	collapse `collapse_commands' [`weight'`exp'] if `touse', by(`byvars') fast `cw'
	
	tokenize `variables'
	while ("`1'" != "") {
		`1'.relabel
		macro shift
	}

	// ADD TO SPREADSHEET
	if "`modify'" == "" {
		#delimit ;
		export excel using "`using'", keepcellfmt
			cell(A3) firstrow(varlabels) sheet("`sheet'", replace);
		#delimit cr
		
		* Add title
		putexcel set "`using'", modify sheet("`sheet'")
		putexcel A1 = ("`title'")
	}
	else {
		#delimit ;
		export excel using "`using'", keepcellfmt
			cell(A3) firstrow(varlabels) sheet("`sheet'", modify);
		#delimit cr

		putexcel set "`using'", modify sheet("`sheet'")
	}

	// OVERRIDE COLUMN LABELS
	tokenize `variables'
	local i = `n_byvars' + 1
	while "`1'" != "" {
		local col: word `i' of `c(ALPHA)'
		putexcel `col'3 = ("``1'.getexcelname'")

		if "``1'.countvar'" != "" {
			local ++i
		}

		macro shift
		local ++i
	}

	restore
end	
