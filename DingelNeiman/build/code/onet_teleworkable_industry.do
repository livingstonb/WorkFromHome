/*
Reads the teleworkable measure constructed by
Dingel and Neiman, and aggregates it by industry.
*/

// Prepare Dingell-Neiman
import delimited "build/input/occupations_workathome.csv", clear
gen soc2010 = substr(onetsoccode, 1, 7)
gen soc3d2010 = substr(soc2010, 1, 4)
replace soc3d2010 = subinstr(soc3d2010, "-", "", .)
destring soc3d2010, replace

* Label 3-digit categories
do "../occupations/build/output/soc3dlabels2010.do"
label values soc3d2010 soc3d2010_lbl

rename teleworkable teletmp
bysort soc2010: egen teleworkable = mean(teletmp)
drop teletmp
duplicates drop soc2010, force
drop onetsoccode title

gen soc6digit = subinstr(soc2010, "-", "", .)
destring soc6digit, force replace
gen soc3digit = floor(soc6digit / 1000)
gen soc5digit = floor(soc6digit / 10)

tempfile dntmp6d dntmp5d dntmp3d

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
import excel "../OES/build/input/nat2d2017", clear firstrow

* Clean
do "../OES/build/code/clean_oes_generic.do" 2017
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
label define naics_lbl 11 "Agriculture, Forestry, Fishing and Hunting", replace
label define naics_lbl 21 "Mining, Quarrying, and Oil and Gas Extraction", add
label define naics_lbl 22 "Utilities", add
label define naics_lbl 23 "Construction", add
label define naics_lbl 31 "Manufacturing", add
label define naics_lbl 42 "Wholesale Trade", add
label define naics_lbl 44 "Retail Trade", add
label define naics_lbl 48 "Transportation and Warehousing", add
label define naics_lbl 51 "Information", add
label define naics_lbl 52 "Finance and Insurance", add
label define naics_lbl 53 "Real Estate and Rental Leasing", add
label define naics_lbl 54 "Professional, Scientific, and Technical Services", add
label define naics_lbl 55 "Management of Companies and Enterprises", add
label define naics_lbl 56 "Administrative and Support and Waste Management and Remediation Services", add
label define naics_lbl 61 "Educational Services", add
label define naics_lbl 62 "Health Card and Social Assistance", add
label define naics_lbl 71 "Arts, Entertainment, and Recreation", add
label define naics_lbl 72 "Accommodation", add
label define naics_lbl 81 "Other Services (except Public Administration)", add
label define naics_lbl 92 "Public Administration", add

recode industry (32/33 = 31) (45 = 44) (49 = 48) (99 = 92)
label values industry naics_lbl

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

save "build/output/DN_by_industry.dta", replace
