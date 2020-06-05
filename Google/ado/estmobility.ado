/* estmobility
Estimates a regression model of log mobility using GMM or nonlinear least squares.
Results are optionally saved to a log file.
*/

program estmobility
	#delimit ;
	syntax varlist, [FD(integer 0)] [XVAR(varlist)] [SCALE(real 0.0676)] [CONSTANT(integer 0)]
		[SAMPLEVAR(varlist)] [STATEFE(integer 0)] [GMM(integer 0)] [ESTNUM(integer 0)]
		[LEADSLAGS(integer 0)] [OTHERVARIABLES(varlist)] [INTERACT(varlist)]
		[DAYFE(integer 0)] [TITLE(string)] [WEEKENDS(integer 0)];
	#delimit cr
	
	* Additional sample restrictions
	local conds
	
	* Macro of linear explanatory variables
	local regressors

	* MACRO FOR POLICY DUMMIES
	local prefix = cond(`fd', "FD_", "")
	local policies `prefix'd_dine_in_ban `prefix'd_school_closure `prefix'd_non_essential_closure `prefix'd_shelter_in_place
	
	* LEADS AND LAGS OF POLICY DUMMIES
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
	
	* ADD OTHER VARIABLES
	local regressors `regressors' `othervariables'
	
	* ADD CONSTANT
	if `gmm' {
		local constexpr = cond(`constant', "- {_cons=0}", "")
	}
	else {
		local constexpr = cond(`constant', "+ {_cons=0}", "")
	}
	
	* STATE FIXED EFFECTS
	if `statefe' & `gmm' {
		local regressors `regressors' i.stateid
	}
	else if `statefe' {
		quietly tab stateid if `samplevar', gen(d_state)
		local regressors `regressors' d_state*
	}
	
	* CALENDAR DAY FIXED EFFECTS
	if `dayfe' {
		quietly tab ndays if `samplevar', gen(d_nday)
		local regressors `regressors' d_nday*
		
		if `statefe' {
			* Avoid collinearity
			drop d_nday1
		}
	}

	* INCLUDE/EXCLUDE WEEKENDS
	if !`weekends' {
		local conds `conds' & !weekend
		if `fd' {
			local conds `conds' & !monday
		}
	}
	
	* SET MACRO FOR NONLINEAR ACTIVE CASES EXPRESSION
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
	
	* MACRO FOR LINEAR TERM
	local linear {xb: `regressors'}

	* SOLVE
	if `gmm' {
		tempvar constvar
		gen `constvar' = 1
		
		local use_noconstant = cond(`constant', "", "noconstant")
		gmm (`depvar' - `cases' - `linear' `constexpr') if `samplevar' `conds', instruments(`regressors' `xvar', `use_noconstant')
	}
	else {
		#delimit ;
		nl (`depvar' = `cases' + `linear'  `constexpr') if `samplevar' `conds', vce(cluster stateid)
			variables(`depvar' `xvar' `lxvar' `regressors' `interact');
		#delimit cr
	}
	
	* SAVE ESTIMATES TABLE AS LOG FILE
	if `estnum' {
		capture mkdir "stats/output/estimates"
		log using "stats/output/estimates/table`estnum'", text replace nomsg
		di "`title'" _n
		di as text "{hline 13}{c +}{hline 94}" _n "VALUE OF LIFE STATISTICS" _n "{hline 13}{c +}{hline 94}" _n
		
		if "`interact'" == "" {
			di "VSL = " as result _b[/alpha0] * (1 / (90 * 100000)) ^ _b[/alpha1]
			di "VSLE = " as result _b[/alpha0] * (1 / (90 * 0.004)) ^ _b[/alpha1]
		}
		else {
			di "Coefficient on cases taken to be alpha_0 + alpha_X * E[`interact']"
			quietly sum `interact' if `samplevar' `conds'
			local alpha0 = _b[/alpha0] + _b[/alphaX] * r(mean)
			
			di "VSL = " as result `alpha0' * (1 / (90 * 100000)) ^ _b[/alpha1]
			di "VSLE = " as result `alpha0' * (1 / (90 * 0.004)) ^ _b[/alpha1]
		}

		estimates
		log close
	}

	* CLEANUP
	capture drop d_state*
	capture drop d_nday*
	capture drop FF*_d_*
	capture drop LL*_d_*
end
