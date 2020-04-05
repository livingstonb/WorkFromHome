program rowdistinct, rclass
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
		
		quietly egen `gen'`i' = rowfirst(`currvars')
		quietly count if !missing(`gen'`i')
		if `r(N)' == 0 {
			drop `gen'`i'
			return scalar ndistinct = `i' - 1
			continue, break
		}
		
		foreach var of local currvars {
			quietly replace `var' = . if `var' == `gen'`i'
		}
		local ++i
	}
	
	tempfile rdfound
	save `rdfound'
	
	use `rdtmp', clear
	quietly merge 1:1 `id' using `rdfound', nogen keepusing(`gen'*)
end
