program rownotequal
/* Generates a variable which returns the value of the first nonmissing entry
in the given row not equal to any of the values in the varlist passed to
values() */
	#delimit ;
	syntax varlist
		[, VALUES(varlist)]
		[, GEN(name)];
	#delimit cr

	if "`values'" == "" {
		egen `gen' = rowfirst(`varlist')
	}
	else {
		* Count number of variables in varlist
		tokenize `varlist'
		local i = 1
		while "``i''" != "" {
			tempvar tmp`i'
			gen `tmp`i'' = ``i'' == 
			local ++i
		}
		local --i
		
		forvalues i = 1/20 {
			tempvar tmp`i'
			
		}
	}
end
