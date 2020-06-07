/*
Estimates a variety of models of log mobility.
*/

estimates clear
adopath + "../ado"

* Read
clear all
set maxvar 10000
use "build/output/cleaned_counties.dta"

* Housekeeping
tsset ctyid date

adopath + "ado"
discard
shell rm -rd "stats/output/estimates/"
capture mkdir "stats/output/estimates"

local begin = "2020-02-24"
local end = "SIP"

* Weekends
gen day_of_week = dow(date)
gen weekend = inlist(day_of_week, 0, 6)

* Create cases variables
do "stats/code/adjust_active_cases.do" 3 0.1 active_cases3
do "stats/code/adjust_active_cases.do" 7 0.1 active_cases7

* Create list of specifications
capture file close record
file open record using "stats/output/estimates/models.txt", write replace text

local n_mavgs 3 7
local vars work rr
local diffs 0 7

local k = 100
foreach n_mavg of local n_mavgs {
foreach suffix of local vars {
foreach diff of local diffs {
	local label = cond("`suffix'"=="work", "Workplaces", "Retail and rec")
	local constant = (`diff' == 0)
	local casevar active_cases`n_mavg'

	* Baseline
	#delimit ;
	local title "`label' `diff'-differenced, `n_mavg'-day mavg cases, baseline";
	estmobility mobility_`suffix',
		xvar(`casevar') begin("`begin'") end("`end'") constant(`constant') estnum(`=`k'+1')
		diff(`diff') title("`title'") exclude(weekend);
	#delimit cr
	file write record "(`=`k'+1') - `title'" _n

	* Adding state FE
	local title "`label' `diff'-differenced, `n_mavg'-day mavg cases, adding state FE"
	if (`diff' == 0) {
		#delimit ;
		estmobility mobility_`suffix',
			xvar(`casevar') begin("`begin'") end("`end'") statefe(1) estnum(`=`k'+2')
			title("`title'") exclude(weekend);
		#delimit cr
	file write record "(`=`k'+2') - `title'" _n
	}

	* Adding day FE
	local title "`label' `diff'-differenced, `n_mavg'-day mavg cases, adding day FE"
	#delimit ;
	estmobility mobility_`suffix',
		xvar(`casevar') begin("`begin'") end("`end'") statefe(`constant') dayfe(1) estnum(`=`k'+3')
		diff(`diff') title("`title'") exclude(weekend);
	#delimit cr
	file write record "(`=`k'+3') - `title'" _n

	* Adding weekends
	local title "`label' `diff'-differenced, `n_mavg'-day mavg cases, adding weekends"
	#delimit ;
	estmobility mobility_`suffix',
		xvar(`casevar') begin("`begin'") end("`end'") statefe(`constant') dayfe(1) estnum(`=`k'+4')
		diff(`diff') title("`title'");
	#delimit cr
	file write record "(`=`k'+4') - `title'" _n

	* Adding leads and lags
	local title "`label' `diff'-differenced, `n_mavg'-day mavg cases, adding leads and lags"
	#delimit ;
	estmobility mobility_`suffix',
		xvar(`casevar') begin("`begin'") end("`end'") statefe(`constant') dayfe(1) estnum(`=`k'+5')
		diff(`diff') leadslags(3) title("`title'");
	#delimit cr
	file write record "(`=`k'+5') - `title'" _n
	
// 	* Baseline with inverse mills
// 	local title "`label' `diff'-differenced, baseline with Heckman correction (A)"
// 	#delimit ;
// 	estmills sample_until_sip ndays d_dine_in_ban d_school_closure
// 		d_non_essential_closure sc_act_cases10
// 		c.ndays##(c.rural c.popdensity c.icubeds c.republican)
// 		if date <= date("2020-04-15", "YMD") & !weekend, gen(imills);
//
// 	estmobility mobility_`suffix',
// 		xvar(act_cases10) begin("`begin'") end("`end'") constant(`=!`fd'') estnum(`=`k'+6')
// 		fd(`fd') othervariables(imills) title("`title'") exclude(weekend);
// 	#delimit cr
// 	drop imills
// 	file write record "(`=`k'+6') - `title'" _n
//	
// 	* Baseline with inverse mills, probit estimated on 2/24-5/24
// 	capture drop imills
// 	local title "`label' in `model', baseline with Heckman correction (B)"
// 	#delimit ;
// 	estmills sample_until_sip ndays d_dine_in_ban d_school_closure
// 		d_non_essential_closure sc_act_cases10
// 		c.ndays##(c.rural c.popdensity c.icubeds c.republican)
// 		if date <= date("2020-05-24", "YMD") & !weekend, gen(imills);
//
// 	estmobility mobility_`suffix',
// 		xvar(act_cases10) begin("`begin'") end("`end'") constant(`=!`fd'') estnum(`=`k'+7')
// 		fd(`fd') othervariables(imills) title("`title'") exclude(weekend);
// 	#delimit cr
// 	drop imills
// 	file write record "(`=`k'+7') - `title'" _n
	
	* Baseline with rural share interaction
	local title "`label' `diff'-differenced, `n_mavg'-day mavg cases, baseline with rural share interaction"
	#delimit ;
	estmobility mobility_`suffix',
		xvar(`casevar') begin("`begin'") end("`end'") constant(`constant') estnum(`=`k'+6')
		diff(`diff') interact(rural) title("`title'") exclude(weekend);
	#delimit cr
	file write record "(`=`k'+6') - `title'" _n
	
	* Extending to 7-days after first day of SIP
	local title "`label' `diff'-differenced, `n_mavg'-day mavg cases, baseline extd to 7d after SIP start"
	#delimit ;
	estmobility mobility_`suffix',
		xvar(`casevar') begin("`begin'") end("`end'") daysafter(7) constant(`constant') estnum(`=`k'+7')
		diff(`diff') title("`title'") exclude(weekend);
	#delimit cr
	file write record "(`=`k'+7') - `title'" _n
	
	* 7 days after SIP with leads and lags
	local title "`label' `diff'-differenced, `n_mavg'-day mavg cases, baseline extd to 7d after SIP start, w/leads and lags"
	#delimit ;
	estmobility mobility_`suffix',
		xvar(`casevar') begin("`begin'") end("`end'") daysafter(7) constant(`constant') estnum(`=`k'+8')
		diff(`diff') title("`title'") exclude(weekend) leadslags(3);
	#delimit cr
	file write record "(`=`k'+8') - `title'" _n
	
	* Increment counter
	local k = `k' + 100
}
}
}

file close record
