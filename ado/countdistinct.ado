program countdistinct
	syntax varname [, INCLUDEMISSING]
	
	tempvar ones
	gen `ones' = 1
	
	tempfile datatmp
	quietly save `datatmp'
	
	collapse (sum) `ones', by(`varlist') fast
	
	if "`includemissing'" == "" {
		quietly drop if missing(`varlist')
	}
	
	di "Distinct values = `c(N)'"
	use `datatmp', clear
end
