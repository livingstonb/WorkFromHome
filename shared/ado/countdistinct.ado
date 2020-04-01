program countdistinct
	syntax varname
	
	tempvar ones
	gen `ones' = 1
	
	tempfile datatmp
	quietly save `datatmp'
	
	collapse (sum) `ones', by(`varlist') fast
	quietly drop if missing(`varlist')
	
	
	di "Distinct values = `c(N)'"
	use `datatmp', clear
end
