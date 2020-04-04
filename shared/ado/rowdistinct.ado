program rowdistinct
	syntax varlist [, GEN(name)] [, ID(name)]
		
	tokenize `varlist'
	local i = 1
	while "``i''" != "" {
		local ++i
	}
	local nvars = `i' - 1
	
	tempfile rdtmp
	save `rdtmp'

	forvalues i = 1/`nvars' {
		local currvars
		forvalues j = `i'/`nvars' {
			local newvar: word `j' of `varlist'
			local currvars `currvars' `newvar'
		}
		
		egen `gen'`i' = rowfirst(`currvars')
		count if !missing(`gen'`i')
		if `r(N)' == 0 {
			drop `gen'`i'
			continue, break
		}
		
		foreach var of local currvars {
			replace `var' = . if `var' == `gen'`i'
		}
		local ++i
	}
	
	tempfile rdfound
	save `rdfound'
	
	use `rdtmp', clear
	merge 1:1 `id' using `rdfound', nogen keepusing(`gen'*)
end
