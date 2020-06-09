/* estmobility
Estimates a regression model of log mobility using GMM or nonlinear least squares.
Results are optionally saved to a log file.

Arguments:
	DIFF : Number of differences to be taken before estimation.
	XVAR : The cases variable, which enters the model as alpha_1 * (scale * xvar) ^ alpha_2.
	SCALE : A scaling factor that multiplies the cases variable.
	CONSTANT : Set to 1 to include a constant.
	STATEFE : Set to 1 to include state fixed effects.
	GMM : Set to 1 to estimate by GMM instead of NL. Does not appear to work.
	ESTNUM : Number to append to name of log file, if applicable.
	LEADSLAGS : Number of leads and lags of policy dummies to include.
	OTHERVARIABLES : Other variables to enter the model linearly.
	INTERACT : An optional variable to interact with the cases expression.
	DAYFE : Set to 1 to include calendar day fixed effects, will not be differenced.
	TITLE : Title of table in log file, if applicable.
	FACTORVARS : Optional variables to include as factors. Enter the model linearly.
	BEGIN : First date to use for sample.
	END : Last date to use for sample. Entering SIP selects the first date of SIP order for county.
	DAYSAFTER : Number of days to include after SIP order goes into effect, if applicable.
	INCLUDE : Binary variable used to force certain observations to be included.
	EXCLUDE : Binary variable used to force certain observations to be excluded.
	INITIAL1 : Initial value for coefficient on cases.
	INITIAL2 : Initial value for exponent on cases.

Example:
	estmobility mobility_work, xvar(cases) constant(1) exclude(weekend)
*/

program estmobility
	#delimit ;
	syntax varlist, [DIFF(integer 0)] [XVAR(varlist)] [SCALE(real 0.0676)] [CONSTANT(integer 0)]
		[STATEFE(integer 0)] [GMM(integer 0)] [ESTNUM(integer 0)]
		[LEADSLAGS(integer 0)] [OTHERVARIABLES(varlist)] [INTERACT(varlist)]
		[DAYFE(integer 0)] [TITLE(string)] [FACTORVARS(varlist)]
		[BEGIN(string)] [END(string)] [DAYSAFTER(integer 0)] [INCLUDE(varlist)] [EXCLUDE(varlist)]
		[INITIAL1(real -1)] [INITIAL2(real 0.25)];
	#delimit cr
	
	* Macro of linear explanatory variables
	local regressors
	
	* Macro for beginning and end of sample
	tempvar date0 date1
	gen `date0' = date("`begin'", "YMD")
	
	if "`end'" == "SIP" {
		gen `date1' = shelter_in_place
		quietly sum shelter_in_place
		replace `date1' = r(max) if missing(shelter_in_place)
		replace `date1' = `date1' + `daysafter'
	}
	else if "`end'" != "" {
		gen `date1' = date("`end'", "YMD")
	}
	else {
		gen `date1' = date("2020-12-31", "YMD")
	}
	
	* SAMPLE RESTRICTIONS
	tempvar in_sample
	gen `in_sample' = inrange(date, `date0', `date1')

	if "`include'" != "" {
		replace `in_sample' = 1 if `include'
	}
	
	if "`exclude'" != "" {
		foreach var of local exclude {
			replace `in_sample' = 0 if `var'
		}
	}
	
	* MACRO FOR POLICY DUMMIES
	local policies d_dine_in_ban d_school_closure d_non_essential_closure d_shelter_in_place
	
	* DIFFERENCES
	if `diff' > 0 {
		local policyvars
		foreach var of local policies {
			local policyvars `policyvars' D`diff'_`var'
			capture gen D`diff'_`var' = S`diff'.`var'
		}
	}
	else {
		local policyvars `policies'
	}
	
	* LEADS AND LAGS OF POLICY DUMMIES
	if `leadslags' {
		capture drop FF*_*
		capture drop LL*_*
		foreach var of local policyvars {
			forvalues z = `leadslags'(-1)1 {
				quietly gen FF`z'_`var' = F`z'.`var'
				local regressors `regressors' FF`z'_`var'
			}
		
			local regressors `regressors' `var'

			forvalues z = 1/`leadslags' {
				quietly gen LL`z'_`var' = L`z'.`var'
				local regressors `regressors' LL`z'_`var'
			}
		}
	}
	else {
		local regressors `policyvars'
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
		quietly tab stateid if `in_sample', gen(d_state)
		local regressors `regressors' d_state*
	}
	
	* CALENDAR DAY FIXED EFFECTS
	if `dayfe' {
		quietly tab ndays if `in_sample', gen(d_nday)
		local regressors `regressors' d_nday*
		
		if `statefe' {
			* Avoid collinearity
			drop d_nday1
		}
	}
	
	* OTHER FACTOR VARIABLES
	if "`factorvars'" != "" {
		capture drop dum_*
		foreach var of local factorvars {
			quietly tab `var' if `in_sample', gen(dum_`var')
			local regressors `regressors' dum_`var'*
		}
	}
	
	* SET MACRO FOR NONLINEAR ACTIVE CASES EXPRESSION
	if `diff' > 0 {
		tempvar lxvar
		gen `lxvar' = L`diff'.`xvar'
		replace `lxvar' = 0 if `xvar' == 0 & missing(`lxvar')
		
		if "`interact'" == "" {
			local cases {alpha0=`initial1'} * ((`scale' * `xvar') ^ {alpha1=`initial2'} - (`scale' * `lxvar') ^ {alpha1})
		}
		else {
			local cases ({alpha0=`initial1'} + {alphaX=0} * `interact') * ((`scale' * `xvar') ^ {alpha1=`initial2'} - (`scale' * `lxvar') ^ {alpha1})
		}
		
		capture drop D`diff'_`varlist'
		gen D`diff'_`varlist' = S`diff'.`varlist'
		local depvar D`diff'_`varlist'
	}
	else {
		if "`interact'" == "" {
			local cases {alpha0=`initial1'} * (`scale' * `xvar') ^ {alpha1=`initial2'}
		}
		else {
			local cases ({alpha0=`initial1'} + {alphaX=0} * `interact') * (`scale' * `xvar') ^ {alpha1=`initial2'}
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
		gmm (`depvar' - `cases' - `linear' `constexpr') if `in_sample', instruments(`regressors' `xvar')
	}
	else {
		#delimit ;
		nl (`depvar' = `cases' + `linear'  `constexpr') if `in_sample', vce(cluster stateid)
			variables(`depvar' `xvar' `lxvar' `regressors' `interact');
		#delimit cr
	}
	
	* SAVE ESTIMATES TABLE AS LOG FILE
	if `estnum' {
		capture mkdir "stats/output/estimates"
		log using "stats/output/estimates/table`estnum'", text replace nomsg name(esttable)
		di "`title'" _n
		di as text "{hline 13}{c +}{hline 94}" _n "VALUE OF LIFE STATISTICS" _n "{hline 13}{c +}{hline 94}" _n
		
		if "`interact'" == "" {
			di "VSL = " as result _b[/alpha0] * (1 / (90 * 100000)) ^ _b[/alpha1]
			di "VSLE = " as result _b[/alpha0] * (1 / (90 * 0.004)) ^ _b[/alpha1]
		}
		else {
			di "Coefficient on cases taken to be alpha_0 + alpha_X * E[`interact']"
			quietly sum `interact' if `in_sample'
			local alpha0 = _b[/alpha0] + _b[/alphaX] * r(mean)
			
			di "VSL = " as result `alpha0' * (1 / (90 * 100000)) ^ _b[/alpha1]
			di "VSLE = " as result `alpha0' * (1 / (90 * 0.004)) ^ _b[/alpha1]
		}

		estimates
		log close esttable
	}

	* CLEANUP
	capture drop d_state*
	capture drop d_nday*
	capture drop FF*_d_*
	capture drop LL*_d_*
	capture drop dum_*
end
