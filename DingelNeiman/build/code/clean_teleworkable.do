/* --- HEADER ---
This script reads the teleworkable measure constructed by
Dingel and Neiman, and aggregates it up to the 3-digit level.
*/

// Prepare OES 6-digit occs for merge
`#PREREQ' use "build/temp/nat3d2017.dta", clear

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
	collapse (sum) employment (firstnm) occ_title, by(sector soc2010)

	if `digit' == 3 {
		rename soc2010 soc3digit
	}
	else if `digit' == 5 {
		rename soc2010 soc5digit
	}

	tempfile oestmp`digit'
	save `oestmp`digit'', replace
	restore
}

clear
use `oestmp5'

// Load Dingell-Neiman
`#PREREQ' use "build/temp/DN_temp.dta", clear
rename teleworkable teletmp

* Use value ending in .00 if available
gen detailed = (substr(onetsoccode, 8, 3) == ".00")
gen teledetailed = teletmp if detailed
bysort soc2010: egen detailed_present = total(detailed)
drop if detailed_present & !detailed

* Assume each 8-digit occupation has same employment share within 6-digit occ
bysort soc2010: egen telemean = mean(teletmp)

* Create teleworkable variable
gen teleworkable = teledetailed if detailed
replace teleworkable = telemean if !detailed

drop title onetsoccode teletmp teledetailed telemean
drop detailed_present detailed
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
merge m:1 soc2010 sector using `oestmp6', keep(1 3) keepusing(employment occ_title) nogen

* Aggregate up to the 5-digit level
rename teleworkable tele6d
`#PREREQ' do "build/code/aggregate.do" soc5digit tele6d tele5d
rename employment emp6d

* Merge at 5 digit level
#delimit ;
merge m:1 soc5digit sector using `oestmp5',
	keep(1 3) update keepusing(employment) nogen;
#delimit cr

* Aggregate up to the 3-digit level
preserve
duplicates drop soc5digit sector, force

do "build/code/aggregate.do" soc3d2010 tele5d tele3d
duplicates drop soc3d2010 sector, force
drop employment

tempfile agg3d
save `agg3d'
restore

rename employment emp5d
merge m:1 soc3d2010 sector using `agg3d', nogen keepusing(tele3d)

* Merge at 3 digit level
#delimit ;
merge m:1 soc3digit sector using `oestmp3',
	keep(1 3) update keepusing(employment) nogen;
#delimit cr

// 3-digit level
preserve

rename tele3d teleworkable

duplicates drop soc3d2010 sector, force
drop if missing(sector, soc3d2010)

keep soc3d2010 sector teleworkable employment
order soc3d2010 sector teleworkable employment
sort soc3d2010 sector

`#TARGET' save "build/output/DN_3digit.dta", replace
restore

// 6-digit level
preserve

rename tele6d teleworkable

drop employment
rename emp6d employment

* Re-classify some occupations with "manual alternative"
replace teleworkable = 1 if (soc5digit == "13-1130")
replace teleworkable = 1 if (soc5digit == "13-2080")
replace teleworkable = 1 if (soc5digit == "19-3050")
replace teleworkable = 1 if (soc5digit == "41-3040")
replace teleworkable = 1 if (soc5digit == "43-2020")
replace teleworkable = 1 if (soc5digit == "43-4180")
replace teleworkable = 1 if (soc5digit == "13-2070")
replace teleworkable = 1 if (soc5digit == "17-3020")
replace teleworkable = 0 if (soc5digit == "39-3010")
replace teleworkable = 0 if (soc5digit == "25-2050")
replace teleworkable = 0 if (soc5digit == "27-2020")
replace teleworkable = 0 if (soc5digit == "25-2010")
replace teleworkable = 0 if (soc5digit == "25-4020")
replace teleworkable = 0 if (soc5digit == "25-4030")
replace teleworkable = 0 if (soc5digit == "27-4020")
replace teleworkable = 0 if (soc5digit == "33-9020")
replace teleworkable = 0 if (soc5digit == "39-3030")
replace teleworkable = 0 if (soc5digit == "39-9010")
replace teleworkable = 0 if (soc5digit == "39-9040")
replace teleworkable = 0 if (soc5digit == "43-1010")
replace teleworkable = 0 if (soc5digit == "43-5020")
replace teleworkable = 0 if (soc5digit == "43-9050")
replace teleworkable = 0 if (soc5digit == "43-9070")

duplicates drop soc2010 sector, force
drop if missing(sector, soc2010)
keep soc2010 sector teleworkable employment occ_title
order soc2010 occ_title sector teleworkable employment
sort soc2010 sector

replace employment = 0 if missing(employment)

`#TARGET' save "build/output/DN_6digit.dta", replace
restore

