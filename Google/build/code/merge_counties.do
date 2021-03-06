/*
Merges various datasets to produce a county-level panel.
*/

adopath + "../ado"

* Start with population data
import delimited "build/input/county_populations.csv", clear varnames(1)
drop if county == 0

gen fips = state * 1000
replace fips = fips + county

drop state county
rename stname state
rename ctyname county
rename popestimate2019 population

* Rename for consistency with other datasets
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

drop if state == "District of Columbia"

* Create one row for each date
local last_date = date("2020-06-01", "YMD")
local first_date = date("2020-02-10", "YMD")
local dur = `last_date' - `first_date'

expand `dur' + 1
bysort fips: gen date = `first_date' + _n - 1
format %td date

replace county = subinstr(county, " City and Borough", "", .) if state == "Alaska"
replace county = subinstr(county, " Borough", "", .) if state == "Alaska" & strpos(county, "Kenai") == 0
replace county = subinstr(county, " Census Area", "", .) if state == "Alaska"

* Merge with mobility
sort state county date
merge 1:1 state county date using "build/temp/mobility_counties.dta", nogen keep(1 3)

* Merge with spending
sort fips date
merge 1:1 fips date using "build/temp/spending.dta", nogen keep(1 3)
gen lspending = log(1 + spending)
label variable lspending "Log expenditures"

* Combine NYC since COVID cases & deaths are aggregated for NYC
preserve
keep if inlist(county, "New York", "Kings", "Queens", "Bronx", "Richmond") & state == "New York"

rename population wgts
gen population = 1
collapse (mean) mobility_work (mean) mobility_rr (mean) spending (sum) population [fw=wgts], by(date)

gen fips = 99991
gen county = "New York City"
gen state = "New York"

tempfile nydata
save `nydata'
restore

drop if inlist(county, "New York", "Kings", "Queens", "Bronx", "Richmond") & state == "New York"
append using `nydata'

* Merge with covid cases
preserve
import delimited "build/input/covid_counties.csv", clear varnames(1)

rename date tmp_date
gen date = date(tmp_date, "YMD")
format date %td
drop tmp_date

replace fips = 99991 if county == "New York City"
drop if missing(fips)

keep fips cases deaths date

tempfile coviddata
save `coviddata'
restore

merge 1:1 fips date using `coviddata', keep(1 3) nogen

* Missing cases & deaths should be zeros per NYT (up until last date used)
quietly sum date if !missing(cases)

replace cases = 0 if missing(cases) & date <= r(max)
replace deaths = 0 if missing(deaths) & date <= r(max)

* Remove counties overlapping Kansas city per NYT
drop if (state == "Missouri") & inlist(county, "Cass", "Jackson", "Clay", "Platte")

* Merge with state-level data
merge m:1 state using "build/temp/dine_in_bans.dta", nogen keep(1 3)
merge m:1 state using "build/temp/stay_at_home.dta", nogen keep (1 3)
rename stay_at_home shelter_in_place
merge m:1 state using "build/temp/cleaned_npis.dta", nogen keep(1 3) keepusing(non_essential_closure)
merge m:1 state using "build/temp/school_closures.dta", nogen keep(1 3)

* County id
gen ctyid = fips

* Recode mobility
replace mobility_rr = log(1 + mobility_rr / 100)
replace mobility_work = log(1 + mobility_work / 100)

label variable mobility_work "Log mobility, workplaces"
label variable mobility_rr "Log mobility, retail and rec"

* Recode cases and deaths as per capita
replace cases = cases / population
replace deaths = deaths / population

* Merge IHME data
rename state statename
merge m:1 statename using "build/output/ihme_summary_stats.dta", nogen keep(1 3) keepusing(lifted_shelter_in_place)

* Intervention dates from JHU
merge m:1 fips using "build/temp/jhu_interventions.dta", keep(1 3)
rename jhu_entertainment_closure jhu_entertainment

* New SIP variable using our state-level variable and JHU's county-specific in some cases
rename shelter_in_place our_shelter_in_place
bysort statename: egen jhu_state_sip = mode(jhu_shelter_in_place), maxmode

gen shelter_in_place = our_shelter_in_place if (jhu_shelter_in_place == jhu_state_sip)
replace shelter_in_place = min(jhu_shelter_in_place, our_shelter_in_place) if (jhu_shelter_in_place != jhu_state_sip)
format %td shelter_in_place
drop jhu_state_sip

* Policy dummies
tsset ctyid date

local policies non_essential_closure school_closure dine_in_ban shelter_in_place
foreach policy of local policies {
	gen d_`policy' = (date >= `policy') & !missing(`policy')
}

gen d_lifted_shelter_in_place = (date >= lifted_shelter_in_place) & !missing(lifted_shelter_in_place)
replace d_shelter_in_place = 0 if d_lifted_shelter_in_place

* JHU policies
#delimit ;
local policies gathering_ban_50 gathering_ban_500 shelter_in_place dine_in_ban
	school_closure entertainment;
#delimit cr
foreach policy of local policies {
	gen jhu_d_`policy' = (date >= jhu_`policy') & !missing(jhu_`policy')
}
replace jhu_d_shelter_in_place = 0 if d_lifted_shelter_in_place

* Other JHU variables
merge m:1 fips using "build/temp/jhu_summary.dta", nogen keep(1 3)
replace icubeds = icubeds / population

* March 13th dummy
gen d_march13 = date >= date("2020-03-13", "YMD")

* State identifier
encode statename, gen(stateid)

* Merge land area
merge m:1 statename county using "build/temp/county_land_areas.dta", nogen keep(1 3)
gen popdensity = population / land

* Merge fraction democrat
// merge m:1 statename using "build/temp/party_affiliation.dta", nogen keep(1 3)
merge m:1 fips using "build/temp/election_results.dta", nogen keep(1 3)


* Population weights
gen wgts = population / 10000

* Linear trend
tsset ctyid date
local day1 = date("2020-02-29", "YMD")
gen ndays = date - `day1'

* Temperature trend
gen day_of_year = doy(date)
gen temperature = tempf_b0 + tempf_b1 * day_of_year
drop tempf_b0 tempf_b1 day_of_year

* Save
save "build/output/cleaned_counties.dta", replace
