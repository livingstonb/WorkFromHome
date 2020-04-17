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

	* Loop over variables
	local icol = `n_byvars'
	foreach var of local variables {

		* Loop over sub-variables
		forvalues subv = 1/``var'.cmd.n' {
			local iletter1 = floor(`icol' / 26)
			local iletter2 = mod(`icol', 26) + 1
			capture local letter1: word `iletter1' of `c(ALPHA)'
			local letter2: word `iletter2' of `c(ALPHA)'
			putexcel `letter1'`letter2'3 = ("``var'.getexcelname `subv''")

			local ++icol
		}

		if "``var'.countvar'" != "" {
			local ++icol
		}
	}

	restore
end