program varlabels
	syntax [varlist] [, RESTORE] [, SAVE]

	if ("`save'" != "") & ("`restore'" != "") {
		di "Cannot use both restore and save options"
		error 1
	}

	if "`varlist'" == "" {
		quietly ds
		local varlist `r(varlist)'
	}

	if "`save'" == "save" {
		quietly {
			._varnames_ = .statalist.new`'
			._varlabels_ = .statalist.new
			foreach var of varlist `varlist' {
				local lab: variable label `var'
				._varlabels_.append "`lab'"
				._varnames_.append "`var'"
			}
		}
	}
	else if "`restore'" == "restore" {
		quietly {
			._varnames_.loop_reset
			._varlabels_.loop_reset
			while (`._varnames_.loop_next' & `._varlabels_.loop_next') {
				local var `._varnames_.loop_get'
				capture quietly ds `var'*
				if _rc == 0 {
					local currvarlist `r(varlist)'
					foreach subvar of local currvarlist {
						capture label variable `subvar' "`._varlabels_.loop_get'"
					}
				}
			}

			classutil drop ._varnames_
			classutil drop ._varlabels_
		}
	}
	else {
		di "Must use option restore or option save"
		error 1
	}
end