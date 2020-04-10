program expand_industries
	#delimit ;
	syntax varname [, VALUES(string)]
		[, INDICATOR(string)] [, EMPVAR(string)];
	#delimit cr
	
	tokenize `values'
	local n = 0
	while ("`1'" != "") {
		local ++n
		macro shift
	}

	expand `n' if `indicator'
	
	tempvar iexpand
	gen `iexpand' = sum(`indicator') if `indicator'
	
	tokenize `values'
	local i = 1
	while ("`1'" != "") {
		replace `varlist' = `1' if (`iexpand' == `i')
		macro shift
		local ++i
	}
	replace `empvar' = `empvar' / `n' if `indicator'
end
