/* --- HEADER ---
This script reads the teleworkable measure constructed by
Dingel and Neiman, and aggregates it up to the 3-digit level.
*/

// Prepare OES 6-digit occs for merge
`#PREREQ' use "build/temp/nat3d2017.dta", clear

* Collapse by sector and detailed occupation
rename occ_code soc2010
rename tot_emp employment

* 3-digit aggregation
preserve
keep if minor_level
collapse (sum) employment, by(sector soc3d2010)
tempfile oestmp3
save `oestmp3'
restore

* 5-digit aggregation
preserve
keep if broad_level
collapse (sum) employment, by(sector soc5d2010)
tempfile oestmp5
save `oestmp5'
restore

* 6-digit aggregation
preserve
keep if detailed_level
collapse (sum) employment, by(sector soc2010)
tempfile oestmp6
save `oestmp6'
restore

// Read teleworkable measure
clear
`#PREREQ' import delimited "build/input/occupations_workathome.csv"
gen soc2010 = substr(onetsoccode, 1, 7)
gen soc3d2010 = substr(soc2010, 1, 4)
replace soc3d2010 = subinstr(soc3d2010, "-", "", .)
destring soc3d2010, replace

* Label 3-digit categories
`#PREREQ' do "../occupations/build/output/soc3dlabels2010.do"
label values soc3d2010 soc3d2010_lbl
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
gen soc5d2010 = substr(soc2010, 1, 6)
replace soc5d2010 = subinstr(soc5d2010, "-", "", .)
destring soc5d2010, force replace

* Merge at 6 digit level, where possible
merge m:1 soc2010 sector using `oestmp6', keep(1 3) keepusing(employment) nogen

* Aggregate up to the 5-digit level
rename teleworkable tele6d
`#PREREQ' do "build/code/aggregate.do" soc5d2010 tele6d tele5d
rename employment emp6d

* Merge at 5 digit level
#delimit ;
merge m:1 soc5d2010 sector using `oestmp5',
	keep(1 3) update keepusing(employment) nogen;
#delimit cr

* Aggregate up to the 3-digit level
preserve
duplicates drop soc5d2010 sector, force

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
merge m:1 soc3d2010 sector using `oestmp3',
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

// 5-digit level
preserve

rename tele5d teleworkable

drop employment
rename emp5d employment

* Re-classify some occupations with "manual alternative"
replace teleworkable = 1 if (soc5d2010 == 13113)
replace teleworkable = 1 if (soc5d2010 == 13208)
replace teleworkable = 1 if (soc5d2010 == 19305)
replace teleworkable = 1 if (soc5d2010 == 41304)
replace teleworkable = 1 if (soc5d2010 == 43202)
replace teleworkable = 1 if (soc5d2010 == 43418)
replace teleworkable = 1 if (soc5d2010 == 13207)
replace teleworkable = 1 if (soc5d2010 == 17302)
replace teleworkable = 0 if (soc5d2010 == 39301)
replace teleworkable = 0 if (soc5d2010 == 25205)
replace teleworkable = 0 if (soc5d2010 == 27202)
replace teleworkable = 0 if (soc5d2010 == 25201)
replace teleworkable = 0 if (soc5d2010 == 25402)
replace teleworkable = 0 if (soc5d2010 == 25403)
replace teleworkable = 0 if (soc5d2010 == 27402)
replace teleworkable = 0 if (soc5d2010 == 33902)
replace teleworkable = 0 if (soc5d2010 == 39303)
replace teleworkable = 0 if (soc5d2010 == 39901)
replace teleworkable = 0 if (soc5d2010 == 39904)
replace teleworkable = 0 if (soc5d2010 == 43101)
replace teleworkable = 0 if (soc5d2010 == 43502)
replace teleworkable = 0 if (soc5d2010 == 43905)
replace teleworkable = 0 if (soc5d2010 == 43907)

duplicates drop soc5d2010 sector, force
drop if missing(sector, soc5d2010)
keep soc5d2010 sector teleworkable employment
order soc5d2010 sector teleworkable employment
sort soc5d2010 sector

replace employment = 0 if missing(employment)

`#TARGET' save "build/output/DN_5digit.dta", replace
restore