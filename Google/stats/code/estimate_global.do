
use "build/output/cleaned_global.dta", clear

* Housekeeping
adopath + "ado"
discard
shell rm -rd "stats/output/estimates/"
capture mkdir "stats/output"
capture mkdir "stats/output/estimates"

local begin = "2020-02-17"
local end = "2020-06-08"

* Days after first day of sample
gen ndays = date - date("`begin'", "YMD")

* Weekends
gen day_of_week = dow(date)
gen weekend = inlist(day_of_week, 0, 6)

* Stringency squared
gen sq_stringency = stringency ^ 2

* Cases, 5-day moving avg
cleantimeseries active_cases, ma(5) gen(mavg5_active_cases) panelid(cntryid)
label variable mavg5_active_cases "active cases 5-day moving avg"

* Deaths, 5-day moving avg
cleantimeseries deaths, ma(5) gen(mavg5_deaths) panelid(cntryid)
label variable mavg5_deaths "deaths 5-day moving avg"

* Deaths, 15 day lead
gen F15_mavg5_deaths = max(F15.mavg5_deaths, 0)
label variable F15_mavg5_deaths "15-day lead of 5-day mavg of deaths"

* Deaths 15 day lead of new deaths
gen DF15_mavg5_deaths = max(D.F15_mavg5_deaths, 0)
label variable DF15_mavg5_deaths "first difference of 15-day lead of 5-day mavg of deaths"

// * Create cases variables, 0.1 recovery rate with 3-day moving avg
// #delimit ;
// cleantimeseries cases,
// 	ma(3) recovery(0.1) gen(mavg3_approx_active_cases) initial("2020-02-17") panelid(cntryid);
// #delimit cr

* Create list of specifications
capture file close record
file open record using "stats/output/estimates/models.txt", write replace text

* Loop over mobility variables
local depvars mobility_work mobility_rr

* Loop over independent variables
local indepvars mavg5_active_cases mavg5_deaths F15_mavg5_deaths DF15_mavg5_deaths

* First diff vs 7-day diff
local diffs 0 7

local k = 100
foreach depvar of local depvars {
forvalues weighted = 0/1 {
foreach indepvar of local indepvars {
foreach diff of local diffs {
	local countryfe = cond(`diff'==0, "cntryid", "")
	local lab1: variable label `depvar'
	local lab2: variable label `indepvar'
	
	* Scaling factor
	local scale = cond(strpos("`indepvar'", "death") > 0, 1, 0.0676)
	
	* Weighting term
	local weights = cond(`weighted', "[aw=wgts]", "")
	local labw = cond(`weighted', "weighted", "unweighted")
	
	* Test
// 	#delimit ;
// 	estmobility mobility_work [aw=wgts], xvar(DF15_mavg5_deaths)
// 		begin("2020-02-17") end("2020-06-08") constant(1) exclude(weekend)
// 		policies(stringency sq_stringency) clustvar(cntryid) scale(1);
// 	#delimit cr

	* Baseline
	local title "`lab1' `diff'-differenced, using `lab2', baseline, `labw'"
	#delimit ;
	estmobility `depvar' `weights',
			xvar(`indepvar') begin("`begin'") end("`end'") constant(`=(`diff'==0)')
			diff(`diff') exclude(weekend) policies(stringency sq_stringency) clustvar(cntryid)
			estnum(`=`k'+1') title("`title'") scale(`scale');
	#delimit cr
	file write record "(`=`k'+1') - `title'" _n
	
	* Country FE
	if `diff' == 0 {
		local title "`lab1' `diff'-differenced, using `lab2', adding country FE, `labw'"
		#delimit ;
		estmobility `depvar' `weights',
				xvar(`indepvar') begin("`begin'") end("`end'") constant(0)
				diff(`diff') exclude(weekend) policies(stringency sq_stringency) clustvar(cntryid)
				factorvars(cntryid)
				estnum(`=`k'+2') title("`title'") scale(`scale');
		#delimit cr
		file write record "(`=`k'+2') - `title'" _n
	}
	
	* Calendar day FE
	local title "`lab1' `diff'-differenced, using `lab2', adding calendar day FE, `labw'"
	#delimit ;
	estmobility `depvar' `weights',
		xvar(`indepvar') begin("`begin'") end("`end'") constant(0)
		diff(`diff') exclude(weekend) policies(stringency sq_stringency) clustvar(cntryid)
		factorvars(`countryfe' ndays)
		estnum(`=`k'+3') title("`title'") scale(`scale');
	#delimit cr
	file write record "(`=`k'+3') - `title'" _n
	
	* Adding weekends
	local title "`lab1' `diff'-differenced, using `lab2', adding weekends, `labw'"
	#delimit ;
	estmobility `depvar' `weights',
		xvar(`indepvar') begin("`begin'") end("`end'") constant(0)
		diff(`diff') policies(stringency sq_stringency) clustvar(cntryid)
		factorvars(`countryfe' ndays)
		estnum(`=`k'+4') title("`title'") scale(`scale');
	#delimit cr
	file write record "(`=`k'+4') - `title'" _n
	
	* Adding leads and lags
	local title "`lab1' `diff'-differenced, using `lab2', adding leads and lags, `labw'"
	#delimit ;
	estmobility `depvar' `weights',
		xvar(`indepvar') begin("`begin'") end("`end'") constant(0)
		diff(`diff') policies(stringency sq_stringency) clustvar(cntryid)
		factorvars(`countryfe' ndays) leadslags(3)
		estnum(`=`k'+5') title("`title'") scale(`scale');
	#delimit cr
	file write record "(`=`k'+5') - `title'" _n
	
	* Counter
	local k = `k' + 100
}
}
}
}
file close record

