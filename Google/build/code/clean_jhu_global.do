
args variable
// cases or recoveries or deaths

clear
import excel "build/input/global_`variable'.xlsx", allstring

foreach var of varlist E-EL {
	local lab = `var'[1]
	rename `var' `variable'`lab'
	destring `variable'`lab', force replace
}
rename A province
rename B country
drop C D

drop in 1

quietly reshape long `variable', i(province country) j(datestr) string

gen date = date(datestr, "DMY")
drop datestr
format %td date

sort country province date

* Hong Kong
replace country = "Hong Kong" if province == "Hong Kong"

* Australia, Canada, and China reported at the province/state level
gen cntry_acc = inlist(country, "Australia", "Canada", "China")

preserve
collapse (sum) `variable' if cntry_acc, by(country date)

tempfile acc
save `acc'
restore

drop if cntry_acc
append using `acc'
drop cntry_acc

* Some countries list dependencies separately
#delimit ;
replace country = province
	if inlist(country, "Denmark", "United Kingdom", "France", "Netherlands")
		& province != "";
#delimit cr
drop province

* Rename
replace country = "United States" if country == "US"
replace country = "Czech Republic" if country == "Czechia"
replace country = "Slovak Republic" if country == "Slovakia"
replace country = "Cape Verde" if country == "Cabo Verde"
replace country = "Kyrgyz Republic" if country == "Kyrgyzstan"
replace country = "Myanmar" if country == "Burma"
replace country = "South Korea" if country == "Korea, South"
replace country = "Taiwan" if country == "Taiwan*"

sort country date
save "build/temp/global_`variable'.dta", replace
