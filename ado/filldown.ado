program filldown
	syntax varname [, GEN(string)]
	
	tempvar indicator suminds
	gen `indicator' = 1 if !missing(`varlist')
	gen `suminds' = sum(`indicator')

	if "`gen'" == "" {
		tempvar groupval
		bysort `suminds': egen `groupval' = max(`varlist')
		replace `varlist' = `groupval'
	}
	else {
		bysort `suminds': egen `gen' = max(`varlist')
	}
	
end
