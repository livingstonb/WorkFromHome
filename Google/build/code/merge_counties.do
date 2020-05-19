
adopath + "../ado"

* COVID cases and deaths
import delimited "build/input/covid_counties.csv", clear varnames(1)
gen master = 1

rename date tmp_date
gen date = date(tmp_date, "YMD")
format date %td
drop tmp_date

tempfile covidtmp
save `covidtmp'

duplicates drop state county, force
keep county state
local d1 = date("2020-02-15", "YMD")
local d2 = date("2020-05-01", "YMD")

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
merge 1:1 state county date using "build/temp/mobility_counties.dta", nogen keep(1 3)
drop if county == "Unknown"

* Missing cases means county was not listed for a date --> zero cases
bysort state county: egen cases_present = count(cases)
gen make_change = cases_present & missing(cases)
replace cases = 0 if make_change
replace deaths = 0 if make_change
replace master = 1 if make_change
drop make_change cases_present
drop if missing(cases)

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

* Recode cases as per capita
replace cases = cases / population

* Use moving average of cases
rename cases raw_cases
moving_average raw_cases, time(date) panelid(ctyid) gen(cases) nperiods(3)
label variable cases "County cases p.c."

* Create recovery-adjusted cases
tsset ctyid date

gen dcases = D.cases
replace dcases = 0 if (cases == 0) & missing(L.cases)

gen adj_cases90 = cases if date <= date("2020-02-24", "YMD")
by ctyid: replace adj_cases90 = cond(date > date("2020-02-24", "YMD"), max(dcases + 0.9 * adj_cases90[_n-1], 0), adj_cases90)

gen adj_cases80 = cases if date <= date("2020-02-24", "YMD")
by ctyid: replace adj_cases80 = cond(date > date("2020-02-24", "YMD"), max(dcases + 0.8 * adj_cases80[_n-1], 0), adj_cases80)

drop dcases

label variable cases "County cases p.c."
label variable adj_cases90 "County cases p.c. (0.1 rec rate)"
label variable adj_cases80 "County cases p.c. (0.2 rec rate)"

* Dummies
gen d_non_essential_closure = date >= non_essential_closure & !missing(non_essential_closure)
gen d_shelter_in_place = date >= shelter_in_place & !missing(shelter_in_place)
gen d_school_closure = date >= school_closure & !missing(school_closure)
gen d_dine_in_ban = date >= dine_in_ban & !missing(dine_in_ban)

label variable d_non_essential_closure "Non-essential closure"
label variable d_shelter_in_place "Shelter-in-place"
label variable d_school_closure "School closure"
label variable d_dine_in_ban "Dine-in ban"

* Leads and lags
gen Ld_non_essential_closure = LD.d_non_essential_closure
gen Fd_non_essential_closure = FD.d_non_essential_closure
gen Ld_school_closure = LD.d_school_closure
gen Fd_school_closure = FD.d_school_closure
gen Ld_dine_in_ban = LD.d_dine_in_ban
gen Fd_dine_in_ban = Fd.d_dine_in_ban
gen Fd_shelter_in_place = Fd.d_shelter_in_place

label variable Ld_non_essential_closure "Lag, non-essential closure"
label variable Ld_school_closure "Lag, school closure"
label variable Ld_dine_in_ban "Lag, dine-in ban"

label variable Fd_non_essential_closure "Lead, non-essential closure"
label variable Fd_shelter_in_place "Lead, shelter-in-place"
label variable Fd_school_closure "Lead, school closure"
label variable Fd_dine_in_ban "Lead, dine-in ban"

* March 13th dummy
gen d_march13 = date >= date("2020-03-13", "YMD")

* State identifier
rename state statename
encode statename, gen(stateid)

* Save
save "build/output/cleaned_counties.dta", replace
