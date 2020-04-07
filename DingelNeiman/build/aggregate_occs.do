

// Prepare OES 6-digit occs for merge
use "$OESbuild/output/oes_cleaned.dta", clear
rename OCC_CODE soc2010

* 1-digit first
rename ind1d naics2017
#delimit ;
merge m:1 naics2017 using "$WFHshared/industries/output/naicsindex2017.dta",
	keepusing(sector) keep(1 3 4) nogen;
#delimit cr
rename naics2017 ind1d

* 2-digit
rename ind2d naics2017
#delimit ;
merge m:1 naics2017 using "$WFHshared/industries/output/naicsindex2017.dta",
	keepusing(sector) keep(1 3 4) nogen update;
#delimit cr
rename naics2017 ind2d

* 3-digit
rename ind3d naics2017
#delimit ;
merge m:1 naics2017 using "$WFHshared/industries/output/naicsindex2017.dta",
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

save "$DNout/DN_aggregated.dta", replace
