/* --- HEADER ---
This script reads the teleworkable measure constructed by
Dingel and Neiman, and aggregates it up to the 3-digit level.
*/

// Prepare OES 6-digit occs for merge
import excel "../OES/build/input/nat3d2017", clear firstrow

* Clean
`#PREREQ' do "../OES/build/code/clean_oes_generic.do" 2017

* Merge with sector
`#PREREQ' ``"../industries/build/output/naicsindex2017.dta"''
`#PREREQ' do "../OES/build/code/merge_with_sector.do"

* Collapse by sector and detailed occupation
rename occ_code soc2010
rename tot_emp employment

local digits 3 5 6
local lvls minor broad detailed

forvalues i = 1/3 {
	local digit: word `i' of `digits'
	local lvl: word `i' of `lvls'

	preserve
	keep if occ_group == "`lvl'"
	collapse (sum) employment, by(sector soc2010)

	if `digit' < 6 {
		rename soc2010 soc`digit'digit
	}

	tempfile oestmp`digit'
	save `oestmp`digit'', replace
	restore
}

// Load Dingell-Neiman
`#PREREQ' use "build/temp/DN_temp.dta", clear

* Assume each 8-digit occupation has same employment share within 6-digit occ
rename teleworkable teletmp
bysort soc2010: egen teleworkable = mean(teletmp)
drop title onetsoccode teletmp
duplicates drop soc2010, force

expand 2, gen(sector)

* Some occupations in OES only provided at 5-digit or 3-digit level
gen soc5digit = substr(soc2010, 1, 6)
replace soc5digit = soc5digit + "0"

gen soc3digit = substr(soc2010, 1, 4)
replace soc3digit = soc3digit + "000"
replace soc3digit = "15-1100" if soc3digit == "15-1000"
replace soc3digit = "51-5100" if soc3digit == "51-5000"

* Merge at 6 digit level, where possible
merge m:1 soc2010 sector using `oestmp6', keep(1 3) keepusing(employment) nogen

* Aggregate to 5 digit level
gen missings = missing(employment)
bysort soc5digit sector: egen missing_employment = max(missings)
bysort soc5digit sector: egen agg_employment = total(employment)
replace agg_employment = . if (missing_employment == 1)

* Use weighted mean if employment was present
gen tele_weighted = teleworkable * employment / agg_employment
bysort soc5digit sector: egen agg_teleworkable = total(tele_weighted), missing

* Take mean if employment was missing
bysort soc5digit sector: egen mean_teleworkable = mean(teleworkable)
replace teleworkable = agg_teleworkable
replace teleworkable = mean_teleworkable if (missing_employment == 1)

drop tele_weighted employment *_teleworkable agg_employment miss*
duplicates drop soc5digit sector, force

* Merge at 5 digit level
merge m:1 soc5digit sector using `oestmp5', keep(1 3) update keepusing(employment) nogen

* Aggregate to 3 digit level
gen missings = missing(employment)
bysort soc3d2010 sector: egen missing_employment = max(missings)
bysort soc3d2010 sector: egen agg_employment = total(employment)
replace agg_employment = . if (missing_employment == 1)

* Use weighted mean if employment was present
gen tele_weighted = teleworkable * employment / agg_employment
bysort soc3d2010 sector: egen agg_teleworkable = total(tele_weighted), missing

* Take mean if employment was missing
bysort soc3d2010 sector: egen mean_teleworkable = mean(teleworkable)
replace teleworkable = agg_teleworkable
replace teleworkable = mean_teleworkable if (missing_employment == 1)

drop tele_weighted employment *_teleworkable agg_employment miss*
duplicates drop soc3d2010 sector, force

* Merge again, this time to recover full employment statistics
merge m:1 soc3digit sector using `oestmp3', keep(1 3) keepusing(employment) nogen
drop soc5digit soc3digit soc2010
duplicates drop soc3d2010 sector, force
drop if missing(sector, soc3d2010)
order soc3d2010 sector teleworkable employment
sort soc3d2010 sector

`#TARGET' save "build/output/DN_aggregated.dta", replace