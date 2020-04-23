/*
Generates new variables containing the set of distinct values taken by
the selected values for each row. The new variables generated are named
based on the stub passed to the gen() option. E.g. if the user passes:

rowdistinct occ*, gen(occdistinct)

Then new variables occdistinct1, occdistinct2, etc... will be created
which, for each row, contain the distinct values taken by variables
matching the pattern occ*. The number of variables generated will equal
the maximum number of distinct values across observations.
*/
program rowdistinct, rclass
	syntax varlist, GEN(name)
	tempfile rdtmp
	save `rdtmp'

	* Count number of variables
	local nvars = 0
	foreach var of varlist `varlist' {
		local ++nvars
	}

	* Create new variables in a separate dataset
	forvalues i = 1/`nvars' {
		* Local containing remaining variables to be processed
		local currvars
		forvalues j = `i'/`nvars' {
			local newvar: word `j' of `varlist'
			local currvars `currvars' `newvar'
		}
		
		quietly egen `gen'`i' = rowfirst(`currvars')

		* Stop if all values of new variable are missing
		quietly count if !missing(`gen'`i')
		if `r(N)' == 0 {
			drop `gen'`i'
			return scalar ndistinct = `i' - 1
			continue, break
		}
		
		* Replace remaining variables with missing when they
		* take already-recorded values
		foreach subvar of local currvars {
			quietly replace `subvar' = . if `subvar' == `gen'`i'
		}
		local ++i
	}
	drop `varlist'
	tempfile rdfound
	save `rdfound'
	
	* Revert to original dataset and merge in distinct values
	use `rdtmp', clear
	quietly merge 1:1 _n using `rdfound', nogen keepusing(`gen'*)
end
