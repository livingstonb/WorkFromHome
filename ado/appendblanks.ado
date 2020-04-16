program appendblanks
	#delimit ;
	syntax namelist using/
		[, GEN(string)] [, OVER1(string)] [, OVER2(string)]
		[, VALUES1(string)] [, VALUES2(string)] [, RENAME(string)];
	#delimit cr

	preserve
	clear

	tempfile blanks
	save `blanks', emptyok

	if ("`over2'" == "") {
		local loop2 NONE
	}
	else {
		local loop2 `values2'
	}

	foreach val2 of local loop2 {
	foreach val1 of local values1 {
		use `namelist' using "`using'", clear
		duplicates drop `namelist', force

		if "`rename'" != "" {
			rename `namelist' `rename'
		}

		gen `over1' = `val1'

		if ("`over2'" != "") {
			gen `over2' = `val2'
		}

		gen `gen' = 1

		append using `blanks'
		save `blanks', replace
	}
	}
	
	restore

	gen `gen' = 0
	append using `blanks'
end