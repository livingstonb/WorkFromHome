program appendblanks
	#delimit ;
	syntax namelist using/
		, [OVER1(name) OVER2(name)
		VALUES1(string) VALUES2(string) RENAME(namelist)];
	#delimit cr

	preserve
	clear

	tempfile blanks
	save `blanks', emptyok

	local loop1 = cond("`over1'" != "", "`values1'", "NONE")
	local loop2 = cond("`over2'" != "", "`values2'", "NONE")

	foreach val1 of local loop1 {
	foreach val2 of local loop2 {
		use `namelist' using "`using'", clear
		duplicates drop `namelist', force

		if "`rename'" != "" {
			local i = 0
			foreach new_name of local rename {
				local ++i
				local varname: word `i' of `namelist'
				rename `varname' `new_name'
			}
		}

		capture gen `over1' = `val1'
		capture gen `over2' = `val2'

		gen blankobs = 1

		append using `blanks'
		save `blanks', replace
	}
	}
	
	restore

	gen blankobs = 0
	label define blankobs_lbl 0 "Not missing" 1 "Missing"
	label values blankobs blankobs_lbl
	label variable blankobs "Indicator for missing category"

	append using `blanks'
end