program regmobility

	syntax [anything], [FD(integer 0)] [NATL(integer 0)] [QUAD(integer 0)] [TIMETREND(string)] [SUFFIX(string)] [ESTNAME(string)] [POPWGT(varlist)] [POLICYLAGS(integer 0)]
	
	local prefix = cond(`fd', "D.", "")
	local depvar `prefix'mobility_`suffix'
	
	local natstr = cond(`natl', "natl_", "")
	local varcases `prefix'`natstr'cases
	local varcases_sq = cond(`quad', "`prefix'sq_`natstr'cases", "")
	
	local wgt_macro = cond("`popwgt'"=="", "", "[aw=`popwgt']")
	
	local dt = cond(`fd', "", "ge_")
	local policies d_`dt'school_closure d_`dt'dine_in_ban d_`dt'non_essential_closure
	if `policylags' {
		local policies `policies' L.d_`dt'school_closure L.d_`dt'dine_in_ban L.d_`dt'non_essential_closure
	}

	#delimit ;
	eststo `estname': reg `depvar'
		`varcases' `varcases_sq'
		`policies' d_shelter_in_place `timetrend'
		i.stateid#day_of_week
		`wgt_macro', robust noconstant;
	#delimit cr
end
