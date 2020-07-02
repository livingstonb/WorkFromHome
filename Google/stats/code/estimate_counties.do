/*
Estimates a variety of models of log mobility.

Note: The stats/output/estimates/ directory is deleted by this script and
recreated.
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

local begin = "2020-02-29"
local end = "SIP"

* Weekends
gen day_of_week = dow(date)
gen weekend = inlist(day_of_week, 0, 6)

* Create cases variables, 0.1 recovery rate with 7-day moving avg
do "stats/code/adjust_active_cases.do" cases 7 0.1 active_cases7

* Policy variables reset to zero after SIP
gen adj_dine_in_ban = d_dine_in_ban
replace adj_dine_in_ban = 0 if d_lifted_shelter_in_place

gen adj_non_essential_closure = d_non_essential_closure
replace adj_non_essential_closure = 0 if d_lifted_shelter_in_place

* Variable for SIP order, for exclusion
gen sip_exclude = d_shelter_in_place
replace sip_exclude = 0 if (date == shelter_in_place)

* Policy variables
local policies d_dine_in_ban d_school_closure d_non_essential_closure d_shelter_in_place
local adj_policies adj_dine_in_ban d_school_closure adj_non_essential_closure d_shelter_in_place

* Test
// gen missing_spending = missing(spending)
// local sc = 100000 * 0.058
// #delimit ;
// estmobility mobility_work,
// 	xvar(active_cases3) begin("2020-02-24") end("SIP") constant(1) scale(`sc')
// 	diff(0) exclude(weekend) clustvar(stateid)
// 	policies(d_dine_in_ban d_school_closure d_non_essential_closure d_shelter_in_place);
// #delimit cr

gen D7_lspending = S7.lspending
gen spending_miss = missing(lspending)

local factorvars = "ndays stateid"
local policies d_dine_in_ban d_school_closure d_non_essential_closure d_shelter_in_place

#delimit ;
estmobility mobility_work,
	xvar(active_cases7) begin("2020-02-29") end("SIP") factorvars(`factorvars')
	diff(0) leadslags(3) exclude(weekend spending_miss) clustvar(stateid) policies(`policies');
#delimit cr

* Create list of specifications
capture file close record
file open record using "stats/output/estimates/models.txt", write replace text

* Use 7-day moving avg
local n_mavg 7

* Loop over workplaces mobility, retail and recration mobility
local vars work rr

* Loop over levels and 7-day difference
local diffs 0 7

local k = 100
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
		diff(`diff') title("`title'") exclude(weekend) clustvar(stateid) policies(`policies');
	#delimit cr
	file write record "(`=`k'+1') - `title'" _n

	* Adding state FE
	local title "`label' `diff'-differenced, `n_mavg'-day mavg cases, adding state FE"
	if (`diff' == 0) {
		#delimit ;
		estmobility mobility_`suffix',
			xvar(`casevar') begin("`begin'") end("`end'") factorvars(stateid) estnum(`=`k'+2')
			title("`title'") exclude(weekend) clustvar(stateid) policies(`policies');
		#delimit cr
	file write record "(`=`k'+2') - `title'" _n
	}

	* Adding day FE
	local factorvars = cond(`diff'>0, "ndays", "ndays stateid")
	local title "`label' `diff'-differenced, `n_mavg'-day mavg cases, adding day FE"
	#delimit ;
	estmobility mobility_`suffix',
		xvar(`casevar') begin("`begin'") end("`end'") factorvars(`factorvars') estnum(`=`k'+3')
		diff(`diff') title("`title'") exclude(weekend) clustvar(stateid) policies(`policies');
	#delimit cr
	file write record "(`=`k'+3') - `title'" _n

// 	* Adding weekends
// 	local factorvars = cond(`diff'>0, "ndays", "ndays stateid")
// 	local title "`label' `diff'-differenced, `n_mavg'-day mavg cases, adding weekends"
// 	#delimit ;
// 	estmobility mobility_`suffix',
// 		xvar(`casevar') begin("`begin'") end("`end'") factorvars(`factorvars') estnum(`=`k'+4')
// 		diff(`diff') title("`title'") clustvar(stateid) policies(`policies');
// 	#delimit cr
// 	file write record "(`=`k'+4') - `title'" _n

	* Adding leads and lags
	local factorvars = cond(`diff'>0, "ndays", "ndays stateid")
	local title "`label' `diff'-differenced, `n_mavg'-day mavg cases, adding leads and lags"
	#delimit ;
	estmobility mobility_`suffix',
		xvar(`casevar') begin("`begin'") end("`end'") factorvars(`factorvars') estnum(`=`k'+5')
		diff(`diff') leadslags(3) title("`title'") exclude(weekend) clustvar(stateid) policies(`policies');
	#delimit cr
	file write record "(`=`k'+5') - `title'" _n

	* Adding expenditure variable
	local factorvars = cond(`diff'>0, "ndays", "ndays stateid")
	local title "`label' `diff'-differenced, `n_mavg'-day mavg cases, adding log expenditures"
	#delimit ;
	estmobility mobility_`suffix',
		xvar(`casevar') begin("`begin'") end("`end'") factorvars(`factorvars') estnum(`=`k'+6')
		diff(`diff') leadslags(3) title("`title'") exclude(weekend) clustvar(stateid) policies(`policies')
		othervariables(lspending);
	#delimit cr
	file write record "(`=`k'+6') - `title'" _n
	
// 	* Extending to 7-days after first day of SIP
// 	local factorvars = cond(`diff'>0, "ndays", "ndays stateid")
// 	local title "`label' `diff'-differenced, `n_mavg'-day mavg cases, extd to 7d after SIP start"
// 	#delimit ;
// 	estmobility mobility_`suffix',
// 		xvar(`casevar') begin("`begin'") end("`end'") daysafter(7) factorvars(`factorvars') estnum(`=`k'+7')
// 		diff(`diff') leadslags(3) title("`title'") clustvar(stateid) policies(`policies');
// 	#delimit cr
// 	file write record "(`=`k'+7') - `title'" _n

// 	* Extending to 7-days after first day of SIP
// 	local factorvars = cond(`diff'>0, "ndays", "ndays stateid")
// 	local title "`label' `diff'-differenced, `n_mavg'-day mavg cases, extd to 7d after SIP start"
// 	#delimit ;
// 	estmobility mobility_`suffix',
// 		xvar(`casevar') begin("`begin'") end("`end'") daysafter(7) factorvars(`factorvars') estnum(`=`k'+7')
// 		diff(`diff') leadslags(3) title("`title'") clustvar(stateid) policies(`policies');
// 	#delimit cr
// 	file write record "(`=`k'+7') - `title'" _n

	* Extending to dates after lifting of SIP order, keeping non-essential closure & dine-in ban equal 1
	local factorvars = cond(`diff'>0, "ndays", "ndays stateid")
	local title "`label' `diff'-differenced, `n_mavg'-day mavg cases, extd to after SIP lifted"
	#delimit ;
	estmobility mobility_`suffix',
		xvar(`casevar') begin("`begin'") factorvars(`factorvars') estnum(`=`k'+7')
		diff(`diff') leadslags(3) title("`title'") exclude(sip_exclude weekend) clustvar(stateid) policies(`policies');
	#delimit cr
	file write record "(`=`k'+7') - `title'" _n
	
	* Extending to dates after lifting of SIP order, adjusting non-essential closure & dine-in ban
	local factorvars = cond(`diff'>0, "ndays", "ndays stateid")
	local title "`label' `diff'-differenced, `n_mavg'-day mavg cases, extd to after SIP lifted, policies set to zero upon SIP lifting"
	#delimit ;
	estmobility mobility_`suffix',
		xvar(`casevar') begin("`begin'") factorvars(`factorvars') estnum(`=`k'+8')
		diff(`diff') leadslags(3) title("`title'") exclude(sip_exclude weekend) clustvar(stateid) policies(`adj_policies');
	#delimit cr
	file write record "(`=`k'+8') - `title'" _n
	
	* Regress with county controls
	if `diff' == 0 {
		local factorvars = cond(`diff'>0, "ndays", "ndays stateid")
		local title "`label' `diff'-differenced, `n_mavg'-day mavg cases, county controls"
		#delimit ;
		estmobility mobility_`suffix',
			xvar(`casevar') begin("`begin'") end("`end'") factorvars(`factorvars') estnum(`=`k'+9')
			diff(`diff') leadslags(3) title("`title'") exclude(weekend) clustvar(stateid) policies(`policies')
			othervariables(rural republican popdensity share_* log_median_income icubeds);
		#delimit cr
		file write record "(`=`k'+9') - `title'" _n
	}

	* Increment counter
	local k = `k' + 100
}
}

file close record
