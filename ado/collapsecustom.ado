program collapsecustom
	#delimit ;
	syntax anything(name=variables)
		[fweight pweight iweight] [if] using/
		[, BY(string)]
		[, MODIFY] [, SHEET(string)]
		[, CW];
	#delimit cr

	preserve

	local collapse_commands
	foreach var of local variables {
		local collapse_commands `collapse_commands' ``var'.collapse'
	}
	
	local n_byvars = 0
	local byvars
	foreach byvar of local by {
		local byvars `byvars' ``byvar'.varname'
		`byvar'.dropmissing
		local ++n_byvars
	}

	marksample touse
	#delimit ;
	collapse `collapse_commands' [`weight'`exp'] if `touse',
		by(`byvars') fast `cw';
	#delimit cr

	foreach var of local variables {
		`var'.relabel
	}

	// ADD TO SPREADSHEET
	if "`modify'" == "" {
		local xopt replace
	}
	else {
		local xopt modify
	}

	#delimit ;
	export excel using "`using'", keepcellfmt
		cell(A3) firstrow(varlabels) sheet("`sheet'", `xopt');
	#delimit cr

	putexcel set "`using'", modify sheet("`sheet'")

	// OVERRIDE COLUMN LABELS
	tokenize `variables'
	local icol_alpha = `n_byvars' + 1
	local jcol_alpha = 0

	local kvar = 1
	* Loop over variables
	while "``kvar''" != "" {
		* Loop over sub-variables
		local subv = 0
		while (`subv' < ```kvar''.cmd.n') {
			local ++subv
			if (`jcol_alpha' > 0) {
				local prefix: word `jcol_alpha' of `c(ALPHA)'
			}
			else {
				local prefix
			}

			local col: word `icol_alpha' of `c(ALPHA)'
			putexcel `prefix'`col'3 = ("```kvar''.getexcelname `subv''")

			local ++icol_alpha
			if (`icol_alpha' > 26) {
				local icol_alpha = 1
				local ++jcol_alpha
			}

		}

		if "```kvar''.countvar'" != "" {
			local ++icol_alpha

			if (`icol_alpha' > 26) {
				local icol_alpha = 1
				local ++jcol_alpha
			}
		}

		local ++kvar
	}

	restore
end	
