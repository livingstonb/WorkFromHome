
adopath + "../ado"

* Read COVID cases and deaths
import delimited "build/input/covid_counties.csv", clear varnames(1)
gen master = 1

rename date tmp_date
gen date = date(tmp_date, "YMD")
format date %td
drop tmp_date

tempfile covidtmp
save `covidtmp'

* Create a dataset with no missing dates
duplicates drop state county, force
keep county state
local d1 = date("2020-02-15", "YMD")
local d2 = date("2020-05-29", "YMD")

local diff = `d2' - `d1' + 1
expand `diff'

gen date = date("2020-02-14", "YMD")
bysort state county: replace date = date + _n
format %td date

merge 1:1 state county date using `covidtmp', nogen keep(1 3)

#delimit ;
replace county = subinstr(county, " city", "", .)
	if !(inlist(county, "Fairfax city", "Franklin city",
	"Richmond city", "Roanoke city") & (state == "Virginia"))
	& !(county == "Baltimore city" & state=="Maryland")
	& !(county == "St. Louis city" & state=="Missouri");
#delimit cr

* Merge with mobility
sort state county date
merge 1:1 state county date using "build/temp/mobility_counties.dta", gen(mob_merged)
drop if county == "Unknown"

keep if inlist(mob_merged, 1, 3) | (inlist(county, "New York", "Kings", "Queens", "Bronx", "Richmond") & state == "New York")
drop mob_merged

* Missing cases means county was not listed for a date --> zero cases
bysort state county: egen cases_present = count(cases)
gen make_change = cases_present & missing(cases)
replace cases = 0 if make_change
replace master = 1 if make_change
drop make_change

gen make_change = cases_present & missing(deaths)
replace deaths = 0 if make_change
// replace master = 1 if make_change
drop make_change cases_present

drop if missing(cases) & !(inlist(county, "New York", "Kings", "Queens", "Bronx", "Richmond") & state == "New York")

* Merge with population
preserve

clear
import delimited "build/input/county_populations.csv", clear varnames(1)
drop if county == 0

gen fips = state * 1000
replace fips = fips + county

drop state county
rename stname state
rename ctyname county
rename popestimate2019 population

replace county = subinstr(county, " County", "", .)
replace county = subinstr(county, " Parish", "", .)

#delimit ;
replace county = subinstr(county, " city", "", .)
	if !(inlist(county, "Fairfax city", "Franklin city",
	"Richmond city", "Roanoke city") & (state == "Virginia"))
	& !(county == "Baltimore city" & state=="Maryland")
	& !(county == "St. Louis city" & state=="Missouri");
#delimit cr

replace county = "Anchorage" if county == "Anchorage Municipality"

keep state county population fips

tempfile ctypop
save `ctypop'

restore

merge m:1 state county using `ctypop', nogen keepusing(population fips) update

* Aggregate NY boroughs
preserve

keep if inlist(county, "New York", "Kings", "Queens", "Bronx", "Richmond") & state == "New York"

rename population wgts
gen population = 1
collapse (mean) mobility_rr (mean) mobility_work (sum) population [fw=wgts], by(date)

gen state = "New York"
gen county = "New York City"

tempfile nytmp
save `nytmp'

restore

merge 1:1 state county date using `nytmp', nogen update
drop if inlist(county, "New York", "Kings", "Queens", "Bronx", "Richmond") & state == "New York"

* Drop observations from using
keep if master
drop master

// * Merge with NPIS data
// merge m:1 state using "build/temp/cleaned_npis.dta", nogen keep(1 3)
// drop shelter_in_place
//
// // merge m:1 state county using "build/temp/county_npis.dta"
//
// * Merge with my dataset
// merge m:1 state using "build/temp/stay_at_home.dta", nogen keep (1 3)
// rename stay_at_home shelter_in_place
//
// * Merge with dine-in-bans
// merge m:1 state using "build/temp/dine_in_bans.dta", nogen keep(1 3)

* Merge with state-level data
preserve

use "build/output/cleaned_states.dta", clear

rename population state_population
rename mobility_work state_mob_work
rename mobility_rr state_mob_rr
rename deaths state_deaths
rename cases state_cases

#delimit ;
keep statename date state_* date *mob* school_closure shelter_in_place
	dine_in_ban natl_cases non_essential_closure;
#delimit cr 

tempfile statestemp
save `statestemp'
restore

rename state statename
merge m:1 statename date using `statestemp', nogen keep(1 3)
rename statename state
drop if missing(date)

* County id
egen ctyid = group(state county)

* Recode mobility
replace mobility_rr = log(1 + mobility_rr / 100)
replace mobility_work = log(1 + mobility_work / 100)

label variable mobility_work "Log mobility, workplaces"
label variable mobility_rr "Log mobility, retail and rec"

* Recode cases and deaths as per capita
replace cases = cases / population
replace deaths = deaths / population

* Use moving average of cases
rename cases raw_cases
moving_average raw_cases, time(date) panelid(ctyid) gen(cases) nperiods(3)
label variable cases "County cases p.c."

* Create recovery-adjusted cases
tsset ctyid date

gen dcases = D.cases
replace dcases = 0 if (cases == 0) & missing(L.cases)

local rec_rates 05 10 20

foreach val of local rec_rates {
	gen act_cases`val' = cases if date <= date("2020-02-24", "YMD")
	
	local rrate = `val' / 100
	
	#delimit ;
	by ctyid: replace act_cases`val' =
		cond(date > date("2020-02-24", "YMD"),
			max(dcases + (1 - `rrate') * act_cases`val'[_n-1], 0),
			act_cases`val');
	#delimit cr
	
	label variable act_cases`val' "County cases pc, 0`rrate' rec rate"
}
drop dcases

* Create lags of cases and deaths
foreach var of varlist cases deaths act_cases* {
	gen L_`var' = L.`var'
}

* Dummies
tsset ctyid date

local policies non_essential_closure school_closure dine_in_ban shelter_in_place
foreach policy of local policies {
	gen d_`policy' = (date >= `policy') & !missing(`policy')
	gen Ld_`policy' = (date > `policy') & !missing(`policy')
	gen Fd_`policy' = (date >= `policy' - 1) & !missing(`policy')
}

label variable d_non_essential_closure "Non-essential closure"
label variable d_shelter_in_place "Shelter-in-place"
label variable d_school_closure "School closure"
label variable d_dine_in_ban "Dine-in ban"

label variable Ld_non_essential_closure "Lag, non-essential closure"
label variable Ld_school_closure "Lag, school closure"
label variable Ld_dine_in_ban "Lag, dine-in ban"
label variable Ld_shelter_in_place "Lag, shelter-in-place"

label variable Fd_non_essential_closure "Lead, non-essential closure"
label variable Fd_shelter_in_place "Lead, shelter-in-place"
label variable Fd_school_closure "Lead, school closure"
label variable Fd_dine_in_ban "Lead, dine-in ban"

* March 13th dummy
gen d_march13 = date >= date("2020-03-13", "YMD")

* State identifier
rename state statename
encode statename, gen(stateid)

* Merge land area
merge m:1 statename county using "build/temp/county_land_areas.dta", nogen keep(1 3)
gen popdensity = population / land

* Merge IHME data
merge m:1 statename using "build/output/ihme_summary_stats.dta", keep(1 3) keepusing(lifted_shelter_in_place)

* Save
save "build/output/cleaned_counties.dta", replace
