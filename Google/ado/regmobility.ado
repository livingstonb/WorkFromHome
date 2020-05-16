program regmobility, rclass
	#delimit ;
	syntax [anything], [FD(integer 0)] [NATL(integer 0)] [QUAD(integer 0)]
		[SUFFIX(string)] [ESTNUM(integer 0)] [STATE(integer 0)]
		[POPWGT(integer 0)] [NATQUAD(integer 0)]
		[POLICYVARS(string)];
	#delimit cr
	
	* PREFIX FOR FD
	local FD = cond(`fd', "D.", "")
	
	* DEPENDENT VARIABLE
	local depvar `FD'mobility_`suffix'
	
	* CASES VARIABLES
	local varcases = cond(`state', "`FD'cases", "")

	local varcases = cond(`quad', "`varcases' `FD'sq_cases", "`varcases'")
	local varcases = cond(`natl', "`varcases' `FD'natl_cases", "`varcases'")
	local varcases = cond(`natquad', "`varcases' `FD'sq_natl_cases", "`varcases'")
	
	* POPULATION WEIGHTS
	local wgt_macro = cond(`popwgt', "[aw=wgt]", "")
	
	* MARCH 13 INDICATOR
	local march13 = cond(`fd', "i.stateid#c.d_march13", "i.stateid#c.d_ge_march13")
	
	* DAY-OF-WEEK DUMMIES
// 	if `fd' {
// 		forvalues i = 1/2 {
// 		forvalues j = 0/6 {
// 			local day_dummies `day_dummies' i.stateid#day_of_week
// 		}
// 		}
// 	}
	local day_dummies i.stateid#day_of_week

	#delimit ;
	eststo EST`estnum': reg `depvar'
		`varcases'
		`policyvars'
		`march13'
		`day_dummies'
		`wgt_macro', robust noconstant;
	#delimit cr
end
