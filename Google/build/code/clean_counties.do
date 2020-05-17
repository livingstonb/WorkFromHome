

* COVID cases and deaths
import delimited "build/input/covid_counties.csv", clear varnames(1)
gen master = 1

rename date tmp_date
gen date = date(tmp_date, "YMD")
format date %td
drop tmp_date

#delimit ;
replace county = subinstr(county, " city", "", .)
	if !(inlist(county, "Fairfax city", "Franklin city",
	"Richmond city", "Roanoke city") & (state == "Virginia"))
	& !(county == "Baltimore city" & state=="Maryland")
	& !(county == "St. Louis city" & state=="Missouri");
#delimit cr

* Merge with mobility
sort state county date
merge 1:1 state county date using "build/temp/mobility_counties.dta", nogen

drop if date < date("2020-02-15", "YMD") | date > date("2020-05-02", "YMD")
drop if county == "Unknown"

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

* Merge with NPIS data
merge m:1 state using "build/temp/cleaned_npis.dta", nogen keep(1 3)
drop shelter_in_place

* Merge with my dataset
merge m:1 state using "build/temp/stay_at_home.dta", nogen keep (1 3)
rename stay_at_home shelter_in_place

* Merge with dine-in-bans
merge m:1 state using "build/temp/dine_in_bans.dta", nogen keep(1 3)
