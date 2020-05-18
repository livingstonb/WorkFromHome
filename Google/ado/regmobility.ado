program regmobility, rclass
	#delimit ;
	syntax [anything], [FD(integer 0)] [NATL(integer 0)] [QUAD(integer 0)]
		[SUFFIX(string)] [ESTNUM(integer 0)] [STATE(integer 0)]
		[POPWGT(integer 0)] [NATQUAD(integer 0)] [STDIFF(integer 0)]
		[POLICYVARS(string)] [STDOW(integer 0)] [FULLSAMPLE(integer 0)];
	#delimit cr
	
	* PREFIX FOR FD
	local FD = cond(`fd', "D.", "")
	
	* DEPENDENT VARIABLE
	local depvar `FD'mobility_`suffix'
	
	* CASES VARIABLES
	local varcases = cond(`state', "`FD'cases", "")

	local varcases = cond(`quad', "`varcases' `FD'sq_cases", "`varcases'")
	local varcases = cond(`stdiff', "`varcases' D.cases", "`varcases'")
	local varcases = cond(`natl', "`varcases' `FD'natl_cases", "`varcases'")
	local varcases = cond(`natquad', "`varcases' `FD'sq_natl_cases", "`varcases'")
	
	* POPULATION WEIGHTS
	local wgt_macro = cond(`popwgt', "[aw=wgt]", "")
	
	* DAY-OF-WEEK DUMMIES
	local DST = cond(`stdow', "i.stateid#c.", "")
// 	#delimit ;
// 	local day_dummies `DST'd_dow0 `DST'd_dow1 `DST'd_dow2 `DST'd_dow3
// 		`DST'd_dow4 `DST'd_dow5 `DST'd_dow6;
// 	#delimit cr
// 	local day_dummies `DST'd_dow0 `DST'd_dow6
	
	
	* SAMPLE RESTRICTION
	local sample_macro = cond(`fullsample', "", "if restr_sample")

	#delimit ;
	eststo EST`estnum': reg `depvar'
		`varcases'
		`policyvars'
		`sample_macro'
		`wgt_macro', vce(cluster stateid);
	#delimit cr
end
