


// Prepare OES 6-digit occs for merge
use "$OESbuildtemp/oes_raw.dta", clear

rename OCC_CODE soc2010

replace TOT_EMP = "" if inlist(TOT_EMP, "*", "**")
destring TOT_EMP, replace
rename TOT_EMP employment

* Merge with sector
destring NAICS, replace
gen int ind3d = NAICS / 1000
gen int ind2d = floor(ind3d / 10)
gen int ind1d = floor(ind3d / 100)

* 1-digit first
rename ind1d naics2017
#delimit ;
merge m:1 naics2017 using "$OESbuildtemp/naics_to_sector.dta",
	keepusing(sector) keep(1 3 4) nogen;
#delimit cr
rename naics2017 ind1d

* 2-digit
rename ind2d naics2017
#delimit ;
merge m:1 naics2017 using "$OESbuildtemp/naics_to_sector.dta",
	keepusing(sector) keep(1 3 4) nogen update;
#delimit cr
rename naics2017 ind2d

* 3-digit
rename ind3d naics2017
#delimit ;
merge m:1 naics2017 using "$OESbuildtemp/naics_to_sector.dta",
	keepusing(sector) keep(1 3 4) nogen update;
#delimit cr
rename naics2017 ind3d

* Collapse by sector and detailed occupation
preserve
keep if OCC_GROUP == "detailed"
collapse (sum) employment, by(sector soc2010)

tempfile oestmp6
save `oestmp6', replace
restore

* Collapse by sector and broad occupation
preserve
keep if OCC_GROUP == "broad"
collapse (sum) employment, by(sector soc2010)
rename soc2010 soc5digit

tempfile oestmp5
save `oestmp5', replace
restore

* Collapse by sector and minor occupation
preserve
keep if OCC_GROUP == "minor"
collapse (sum) employment, by(sector soc2010)
rename soc2010 soc3digit

tempfile oestmp3
save `oestmp3', replace
restore

// Load Dingell-Neiman
use "$DNbuildtemp/DN_temp.dta", clear
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
merge m:1 soc2010 sector using `oestmp6', nogen keep(1 3 4) keepusing(employment)

* Aggregate to 5 digit level
bysort soc5digit sector: egen agg_employment = total(employment) if !missing(employment)

gen tele_weighted = teleworkable * employment / agg_employment
bysort soc5digit sector: egen agg_teleworkable = total(tele_weighted)

replace employment = agg_employment
replace teleworkable = agg_teleworkable
drop tele_weighted agg_*

duplicates drop soc5digit sector, force

* Merge at 5 digit level
merge m:1 soc5digit sector using `oestmp5', nogen keep(1 3 4 5) update keepusing(employment)

label define sector_lbl 0 "C" 1 "S"
label variable sector sector_lbl

* Aggregate to 3 digit level
bysort occ3d2010 sector: egen agg_employment = total(employment) if !missing(employment)

gen tele_weighted = teleworkable * employment / agg_employment
bysort occ3d2010 sector: egen agg_teleworkable = total(tele_weighted)

replace employment = agg_employment
replace teleworkable = agg_teleworkable
drop tele_weighted agg_*

duplicates drop occ3d2010 sector, force

* Merge again
merge m:1 soc3digit sector using `oestmp3', nogen keep(1 3 4 5) update replace keepusing(employment)
drop soc5digit soc3d soc2010
