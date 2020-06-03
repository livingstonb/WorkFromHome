




* Read COVID cases and deaths
import delimited "build/input/covid_counties.csv", clear varnames(1)

rename date tmp_date
gen date = date(tmp_date, "YMD")
format date %td
drop tmp_date

replace fips = 99991 if county == "New York City"
replace fips = 99992 if county == "Kansas City"
drop if county == "Unknown"

tempfile covidtmp
save `covidtmp'

* Create a dataset with no missing dates
duplicates drop fips, force
keep fips county state
local d1 = date("2020-01-01", "YMD")
local d2 = date("2020-06-01", "YMD")

local diff = `d2' - `d1' + 1
expand `diff'

gen date = `d1' - 1
bysort fips: replace date = date + _n
format %td date

merge 1:1 fips date using `covidtmp', keepusing(cases deaths) keep(1 3) nogen
drop if date < date("2020-02-15", "YMD")

* Missing cases means county was not listed for a date --> zero cases
replace cases = 0 if missing(cases)
replace deaths = 0 if missing(deaths)

* Merge with JHU data
drop county
merge m:1 fips using "build/temp/jhu_summary.dta", keep(1 3) keepusing(icubeds county) nogen
merge m:1 fips using "build/temp/jhu_interventions.dta", keep(1 3) nogen
rename state statename
bysort fips (county): replace county = county[_N]

* Merge with mobility
replace county = subinstr(county, " City and Borough", "", .) if statename == "Alaska"
replace county = subinstr(county, " Borough", "", .) if statename == "Alaska"
replace county = subinstr(county, " Municipality", "", .) if statename == "Alaska"
replace county = subinstr(county, " Census Area", "", .) if statename == "Alaska"
merge 1:1 statename county date using "build/temp/mobility_for_jhu.dta", keepusing(mobility_work mobility_rr)


* Combine NY boroughs
preserve
keep if inlist(fips, 36005, 36047, 36061, 36081, 36085)

collapse (mean) mobility_work (mean) mobility_rr (sum) icubeds, by(date)
gen fips = 99991

tempfile nydata
save `nydata'
restore

drop if inlist(fips, 36047, 36061, 36081, 36085)
keep if (fips == 36005)
replace fips = 99991 if fips == 36005
replace county = "New York City" if fips == 99991
merge 1:1 fips date using `nydata', update replace

