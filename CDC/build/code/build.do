
adopath + "../ado"

* Read NYT covid cases
clear
import delimited "build/input/covid_states.csv", varnames(1)
rename date tmp_date
gen date = date(tmp_date, "YMD")
format date %td
drop tmp_date

rename state statename

save "build/temp/state_covid_cases.dta", replace

* Read CDC data
clear
import delimited "build/input/covid19-NatEst.csv", varnames(1) rowrange(3)

drop notes

foreach var of varlist _all {
	if !inlist("`var'", "state", "statename", "collectiondate") {
		destring `var', replace
	}
}

gen date = date(collectiondate, "DMY")
format date %td
drop collectiondate
rename state stateid

order state* date

merge 1:1 statename date using "build/temp/state_covid_cases.dta", keep(1 3) nogen

rename icubedsoccanypat__n_icubeds_est icu_occupancy_rate
keep state* date icu_occupancy_rate cases
preserve

* Computed weighted estimates
drop if stateid == "US"
encode stateid, gen(statenum)
tsset statenum date
gen daily_cases = d.cases
replace daily_cases = . if daily_cases < 0
movingavg daily_cases, gen(smoothed_daily_cases) periods(5) time(date) panel(statenum)
collapse (mean) icu_occupancy_rate_weighted=icu_occupancy_rate [aw=smoothed_daily_cases], by(date)

tempfile fulldata
save `fulldata'

restore
keep if stateid == "US"
rename icu_occupancy_rate icu_occupancy_rate_unweighted
merge 1:1 date using `fulldata', nogen

drop cases state*
label variable icu_occupancy_rate_unweighted "National ICU occupancy rate, unweighted"
label variable icu_occupancy_rate_weighted "National ICU occupancy rate, weighted by state cases"

save "build/output/icu_occupancy.dta", replace
