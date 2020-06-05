
adopath + "ado"

discard
// estmobility mobility_work, xvar(act_cases10) fd(0) samplevar(sample_until_sip) constant(0) gmm(1)

shell rm -rd "stats/output/estimates/"

local vars work rr
local models levels FD

local k = 10
foreach suffix of local vars {
foreach model of local models {
	local label = cond("`suffix'"=="work", "Workplaces", "Retail and rec")
	local fd = cond("`model'"=="FD", 1, 0)

	* Baseline
	#delimit ;
	estmobility mobility_work,
		xvar(act_cases10) samplevar(sample_until_sip) constant(1) estnum(`k'+1)
		fd(`fd') title("`label' in `model', baseline");
	#delimit cr

	* Adding state FE
	if !`fd' {
		#delimit ;
		estmobility mobility_work,
			xvar(act_cases10) samplevar(sample_until_sip) statefe(1) estnum(`k'+2)
			title("`label' in `model', with state FE");
		#delimit cr
	}

	* Adding day FE
	#delimit ;
	estmobility mobility_work,
		xvar(act_cases10) samplevar(sample_until_sip) statefe(1) dayfe(1) estnum(`k'+3)
		fd(`fd') title("`label' in `model', with day FE");
	#delimit cr

	* Adding weekends
	#delimit ;
	estmobility mobility_work,
		xvar(act_cases10) samplevar(sample_until_sip) statefe(1) dayfe(1) estnum(`k'+4)
		fd(`fd') weekends(1) title("`label' in `model', with weekends");
	#delimit cr

	* Adding leads and lags
	#delimit ;
	estmobility mobility_work,
		xvar(act_cases10) samplevar(sample_until_sip) statefe(1) dayfe(1) estnum(`k'+5)
		fd(`fd') weekends(1) leadslags(3) title("`label' in `model', with leads and lags");
	#delimit cr
	
	* Increment counter
	local k = `k' + 10
}
}
