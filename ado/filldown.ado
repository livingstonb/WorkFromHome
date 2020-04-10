program filldown
	syntax varname [if/] [, GEN(string)] [, STRING]
	
	tempvar npos marker
	gen `npos' = _n
	
	if "`if'" == "" {
		gen `marker' = 1
	}
	else {
		gen `marker' = `if'
	}

	tempvar indicator suminds
	if "`string'" == "string" {
		gen `indicator' = 1 if `varlist' != "" &  `marker'
	}
	else {
		gen `indicator' = 1 if !missing(`varlist') & `marker'
	}
	gen `suminds' = sum(`indicator') if `marker'

	if "`gen'" == "" {
		tempvar groupval
		if "`string'" == "string" {
			bysort `suminds' (`varlist'): gen `groupval' = `varlist'[_N] if `marker'
		}
		else {
			bysort `suminds' (`varlist'): gen `groupval' = `varlist'[1] if `marker'
		}
		replace `varlist' = `groupval' if `marker'
	}
	else {
		if "`string'" == "string" {
			bysort `suminds' (`varlist'): gen `gen' = `varlist'[_N] if `marker'
		}
		else {
			bysort `suminds' (`varlist'): gen `gen' = `varlist'[1] if `marker'
		}
	}
	
	sort `npos'
end
