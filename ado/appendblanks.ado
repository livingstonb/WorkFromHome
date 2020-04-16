program appendblanks
	#delimit ;
	syntax namelist using/
		[, GEN(string)] [, OVER(string)]
		[, VALUES(string)] [, RENAME(string)];
	#delimit cr

	preserve
	clear

	tempfile blanks
	save `blanks', emptyok

	foreach val of local values {
		use `namelist' using "`using'", clear
		duplicates drop `namelist', force

		if "`rename'" != "" {
			rename `namelist' `rename'
		}

		gen `over' = `val'
		gen `gen' = 1

		append using `blanks'
		save `blanks', replace
	}
	
	restore

	gen `gen' = 0
	append using `blanks'
end