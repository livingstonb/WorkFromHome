program dta_compare
	syntax anything, INDEX(string) [, THRESHOLD(real 0) ALL]

	clear

	local dataset1: word 1 of `anything'
	local dataset2: word 2 of `anything'

	use "`dataset1'"
	gen dataset = 1

	append using "`dataset2'"
	quietly replace dataset = 2 if missing(dataset)

	quietly ds
	local dsvars = "`r(varlist)'"

	sort `index' dataset
	local i = 1
	foreach var of local dsvars {
		if inlist("`var'", "`index'", "dataset") {
			continue
		}

		quietly by `index': gen diff`i' = `var'[2] - `var'[1]
		label variable diff`i' "`var'"

		tempvar bothmissing
		quietly by `index': gen `bothmissing' = (`var'[2] == .) & (`var'[1] == .)
		quietly replace diff`i' = 0 if `bothmissing'
		drop `bothmissing'

		local ++i
	}
	quietly keep if (dataset == 1)

	keep `index' diff*
	foreach var of varlist diff* {
		tempvar absdiff
		quietly gen `absdiff' = abs(`var')
		quietly replace `absdiff' = 0 if (`absdiff' < `threshold')

		quietly sum `absdiff'
		if (`r(sum)' == 0) & ("`all'" != "all"){
			drop `var'
		}
		else {
			rename `var' `: variable label `var''
		}
		drop `absdiff'
	}
end
