/* --- HEADER ---
This script reads the teleworkable measure constructed by
Dingel and Neiman, and aggregates it up to the 3-digit level.
*/

// Prepare Dingell-Neiman
tempfile dntmp6d dntmp5d dntmp3d
`#PREREQ' use "build/temp/DN_temp.dta", clear
rename teleworkable teletmp
bysort soc2010: egen teleworkable = mean(teletmp)
drop teletmp
duplicates drop soc2010, force
drop onetsoccode title

gen soc6digit = subinstr(soc2010, "-", "", .)
destring soc6digit, force replace
gen soc3digit = floor(soc6digit / 1000)
gen soc5digit = floor(soc6digit / 10)

preserve
keep soc6digit teleworkable
save `dntmp6d'
restore

preserve
collapse (mean) teleworkable, by(soc5digit)
save `dntmp5d'
restore

collapse (mean) teleworkable, by(soc3digit)
save `dntmp3d'
clear

// Prepare OES 6-digit occs for merge
`#PREREQ' import excel "../OES/build/input/nat2d2017", clear firstrow

* Clean
`#PREREQ' do "../OES/build/code/clean_oes_generic.do" 2017
rename occ_code soc2010
rename tot_emp employment

gen industry = substr(naicscode, 1, 2)
destring industry, force replace

gen emptemp = employment if occ_group == "total"
bysort industry: egen ind_employment = max(emptemp)
drop emptemp

drop if inlist(occ_group, "total", "major")
keep soc2010 occ_group employment industry ind_employment

* Collapse by industry and detailed occupation
`#PREREQ' do "build/code/group_industries.do" industry

gen soc6digit = subinstr(soc2010, "-", "", .)
destring soc6digit, force replace
gen soc3digit = floor(soc6digit / 1000)
gen soc5digit = floor(soc6digit / 10)

merge m:1 soc6digit using `dntmp6d', nogen keepusing(teleworkable) keep(1 3)
rename teleworkable tele6digit

merge m:1 soc5digit using `dntmp5d', nogen keepusing(teleworkable) keep(1 3)
rename teleworkable tele5digit

merge m:1 soc3digit using `dntmp3d', nogen keepusing(teleworkable) keep(1 3)
rename teleworkable tele3digit

preserve
tempfile tele5d
keep if occ_group == "detailed"

collapse (mean) tele_agg=tele6digit [iw=employment], by(industry soc5digit)
save `tele5d'
restore

merge m:1 industry soc5digit using `tele5d', nogen keepusing(tele_agg) keep(1 3)

preserve
tempfile tele3d
keep if occ_group == "broad"

collapse (mean) tele3tmp=tele5digit [iw=employment], by(industry soc3digit)
save `tele3d'
restore

merge m:1 industry soc3digit using `tele3d', nogen keepusing(tele3tmp) keep(1 3)
replace tele_agg = tele3tmp if missing(tele_agg)
drop tele3tmp
keep if occ_group == "minor"

replace tele_agg = tele3digit if missing(tele_agg)

rename employment wgt
gen employment = 1 if !missing(wgt)
collapse (mean) teleworkable=tele_agg (sum) employment [iw=wgt], by(industry)

label variable teleworkable "Share of workers in teleworkable occupations"
label variable employment "Total employment"
label variable industry "Industry, 2-digit NAICS"

`#TARGET' save "build/output/DN_by_industry.dta", replace
