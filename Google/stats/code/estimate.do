/*
Estimates a variety of models of log mobility.
*/

* Housekeeping
adopath + "ado"
discard
shell rm -rd "stats/output/estimates/"
capture mkdir "stats/output/estimates"

* Create list of specifications
capture file close record
file open record using "stats/output/estimates/models.txt", write replace text

local vars work rr
local models levels FD

local k = 10
foreach suffix of local vars {
foreach model of local models {
	local label = cond("`suffix'"=="work", "Workplaces", "Retail and rec")
	local fd = cond("`model'"=="FD", 1, 0)

	* Baseline
	#delimit ;
	local title "`label' in `model', baseline";
	estmobility mobility_`suffix',
		xvar(act_cases10) samplevar(sample_until_sip) constant(`=!`fd'') estnum(`=`k'+1')
		fd(`fd') title("`title'");
	#delimit cr
	file write record "(`=`k'+1') - `title'" _n

	* Adding state FE
	local title "`label' in `model', with state FE"
	if !`fd' {
		#delimit ;
		estmobility mobility_`suffix',
			xvar(act_cases10) samplevar(sample_until_sip) statefe(1) estnum(`=`k'+2')
			title("`title'");
		#delimit cr
	}
	file write record "(`=`k'+2') - `title'" _n

	* Adding day FE
	local title "`label' in `model', with day FE"
	#delimit ;
	estmobility mobility_`suffix',
		xvar(act_cases10) samplevar(sample_until_sip) statefe(`=!`fd'') dayfe(1) estnum(`=`k'+3')
		fd(`fd') title("`title'");
	#delimit cr
	file write record "(`=`k'+3') - `title'" _n

	* Adding weekends
	local title "`label' in `model', with weekends"
	#delimit ;
	estmobility mobility_`suffix',
		xvar(act_cases10) samplevar(sample_until_sip) statefe(`=!`fd'') dayfe(1) estnum(`=`k'+4')
		fd(`fd') weekends(1) title("`title'");
	#delimit cr
	file write record "(`=`k'+4') - `title'" _n

	* Adding leads and lags
	local title "`label' in `model', with leads and lags"
	#delimit ;
	estmobility mobility_`suffix',
		xvar(act_cases10) samplevar(sample_until_sip) statefe(`=!`fd'') dayfe(1) estnum(`=`k'+5')
		fd(`fd') weekends(1) leadslags(3) title("`title'");
	#delimit cr
	file write record "(`=`k'+5') - `title'" _n
	
	* Baseline with inverse mills
	local title "`label' in `model', baseline with Heckman correction (A)"
	#delimit ;
	estmills sample_until_sip ndays d_dine_in_ban d_school_closure
		d_non_essential_closure sc_act_cases10
		c.ndays##(c.rural c.popdensity c.icubeds c.republican)
		if date <= date("2020-04-15", "YMD") & !weekend, gen(imills);

	estmobility mobility_`suffix',
		xvar(act_cases10) samplevar(sample_until_sip) constant(`=!`fd'') estnum(`=`k'+6')
		fd(`fd') othervariables(imills) title("`title'");
	#delimit cr
	drop imills
	file write record "(`=`k'+6') - `title'" _n
	
	* Baseline with inverse mills, probit estimated on 2/24-5/24
	capture drop imills
	local title "`label' in `model', baseline with Heckman correction (B)"
	#delimit ;
	estmills sample_until_sip ndays d_dine_in_ban d_school_closure
		d_non_essential_closure sc_act_cases10
		c.ndays##(c.rural c.popdensity c.icubeds c.republican)
		if date <= date("2020-05-24", "YMD") & !weekend, gen(imills);

	estmobility mobility_`suffix',
		xvar(act_cases10) samplevar(sample_until_sip) constant(`=!`fd'') estnum(`=`k'+7')
		fd(`fd') othervariables(imills) title("`title'");
	#delimit cr
	drop imills
	file write record "(`=`k'+7') - `title'" _n
	
	* Baseline with rural share interaction
	local title "`label' in `model', baseline with rural share interaction"
	#delimit ;
	estmobility mobility_`suffix',
		xvar(act_cases10) samplevar(sample_until_sip) constant(`=!`fd'') estnum(`=`k'+8')
		fd(`fd') interact(rural) title("`title'");
	#delimit cr
	file write record "(`=`k'+8') - `title'" _n
	
	
	* Increment counter
	local k = `k' + 10
}
}

file close record
