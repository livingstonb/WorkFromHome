program estmobility
	#delimit ;
	syntax varlist, [FD(integer 0)] [XVAR(varlist)] [SCALE(real 0.0676)] [CONSTANT(integer 0)]
		[SAMPLEVAR(varlist)] [STATEFE(integer 0)] [GMM(integer 0)] [ESTNUM(integer 0)]
		[LEADSLAGS(integer 0)] [OTHERVARIABLES(varlist)] [INTERACT(varlist)]
		[DAYFE(integer 0)] [TITLE(string)] [WEEKENDS(integer 0)];
	#delimit cr
	
	local linear
	local conds
	local regressors

	local prefix = cond(`fd', "FD_", "")
	local policies `prefix'd_dine_in_ban `prefix'd_school_closure `prefix'd_non_essential_closure `prefix'd_shelter_in_place
	
	if `leadslags' {
		foreach var of local policies {
			forvalues z = `leadslags'(-1)1 {
				quietly gen FF`z'_`var' = FF`z'.`var'
				local regressors `regressors' FF`z'_`var'
			}
		
			local regressors `regressors' `var'

			forvalues z = 1/`leadslags' {
				quietly gen LL`z'_`var' = LL`z'.`var'
				local regressors `regressors' LL`z'_`var'
			}
		}
	}
	else {
		local regressors `policies'
	}
	
	local regressors `regressors' `othervariables'
	
	local constexpr = cond(`constant', "+ {_cons=0}", "")

	if `statefe' & `gmm' {
		local regressors `regressors' i.stateid
	}
	else if `statefe' {
		quietly tab stateid if `samplevar', gen(d_state)
		local regressors `regressors' d_state*
	}
	
	if `dayfe' {
		quietly tab ndays if `samplevar', gen(d_nday)
		local regressors `regressors' d_nday*
		
		if `statefe' {
			drop d_nday1
		}
	}
	
	if !`weekends' {
		local conds `conds' & !weekend
	}
	
	if `fd' {
		tempvar lxvar
		gen `lxvar' = L.`xvar'
		
		if "`interact'" == "" {
			local cases {alpha0=-1} * ((`scale' * `xvar') ^ {alpha1=0.25} - (`scale' * `lxvar') ^ {alpha1})
		}
		else {
			local cases ({alpha0=-1} + {alphaX=0} * `interact') * ((`scale' * `xvar') ^ {alpha1=0.25} - (`scale' * `lxvar') ^ {alpha1})
		}
		
		capture drop FD_`varlist'
		gen FD_`varlist' = D.`varlist'
		local depvar FD_`varlist'
	}
	else {
		if "`interact'" == "" {
			local cases {alpha0=-1} * (`scale' * `xvar') ^ {alpha1=0.25}
		}
		else {
			local cases ({alpha0=-1} + {alphaX=0} * `interact') * (`scale' * `xvar') ^ {alpha1=0.25}
		}
		
		local lxvar
		local depvar `varlist'
	}
	
	local linear {xb: `regressors'}

	if `gmm' {
		gmm (`depvar' - `cases' - `linear') if `samplevar' `conds', instruments(`regressors' `xvar' L3.`xvar', noconstant)
	}
	else {
		#delimit ;
		nl (`depvar' = `cases' + `linear'  `constexpr') if `samplevar' `conds', vce(cluster stateid)
			variables(`depvar' `xvar' `lxvar' `regressors' `interact');
		#delimit cr
	}
	
	
	if `estnum' {
		capture mkdir "stats/output/estimates"
		log using "stats/output/estimates/table`estnum'", text replace nomsg
		di "`title'"
		estimates
		log close
	}

	capture drop d_state*
	capture drop d_nday*
	capture drop FF*_d_*
	capture drop LL*_d_*
end
