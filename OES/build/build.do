
// clear
//
// import excel using "$OESbuild/input/nat3d_M2017_dl.xlsx", firstrow
// save "$OESbuildtemp/oes_raw.dta", replace

// SAVE .csv AS .dta
clear
import delimited using "$WFHshared/ind2017/naics_to_sector.csv", bindquotes(strict)
drop v1
save "$OESbuildtemp/naics_to_sector.dta", replace

// MERGE WITH SECTOR
use "$OESbuildtemp/oes_raw.dta", clear
keep if OCC_GROUP == "minor"

rename OCC_CODE soc3d2010

* Prepare 2010 SOC index
preserve
tempfile occtmp
use "$WFHshared/occ2010/output/occindex2010new.dta", clear
duplicates drop soc3d2010, force
drop if occ3d2010 > 550
save `occtmp', replace
restore

* Merge with 2010 SOC
#delimit ;
merge m:1 soc3d2010 using `occtmp',
	keepusing(occ3d2010) keep(match master);
#delimit cr

destring NAICS, replace
gen int ind3d = NAICS / 1000
gen int ind2d = floor(ind3d / 10)
gen int ind1d = floor(ind3d / 100)

* 1-digit first
rename ind1d naics2017
#delimit ;
merge m:1 naics2017 using "$OESbuildtemp/naics_to_sector.dta",
	keepusing(sector) keep(1 3 4) nogen update;
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

* Labels
label define sector_lbl 0 "C" 1 "S"
label values sector sector_lbl
label variable sector "Sector"

* Replace ** with missing
#delimit ;
local stringvars
	TOT_EMP PCT_TOTAL H_MEAN H_MEDIAN
	A_MEAN A_MEDIAN;
#delimit cr
foreach var of local stringvars  {
	replace `var' = "" if inlist(`var', "*", "**")
	destring `var', replace
}

* Housekeeping
#delimit ;
keep NAICS NAICS_TITLE soc3d2010 occ3d2010 OCC_GROUP
	`stringvars' sector;
#delimit cr

rename A_MEAN meanwage
label variable meanwage "Mean annual wage"

rename A_MEDIAN medianwage
label variable medianwage "Median annual wage"

rename TOT_EMP employment
label variable employment "Total employment rounded to nearest 10 (excl self-employed)"

rename PCT_TOTAL occshare_industry
label variable occshare_industry "% of industry employment in given occ, provided"

bysort sector occ3d2010: egen emp_occ_sector = total(employment)
label variable emp_occ_sector "Total employment in occupation-sector pair"

bysort sector: egen emp_sector = total(employment)
label variable emp_sector "Total employment in sector"

gen occshare_sector = emp_occ_sector / emp_sector
label variable occshare_sector "Occupation share within sector"
compress

order sector occ3d2010 meanwage occshare_sector occshare_industry

* Add blanks
tempfile yrtmp
preserve
clear
save `yrtmp', emptyok
forvalues sval = 0/1 {
	use occ3d2010 using "$WFHshared/occ2010/output/occindex2010new.dta", clear
	gen sector = `sval'
	gen employment = 1
	gen blankobs = 1
	
	append using `yrtmp'
	save `yrtmp', replace
}
restore
append using `yrtmp'
drop if (occ3d2010 >= 550) & !missing(occ3d2010)
replace blankobs = 0 if missing(blankobs)

* Drop blank observations if categories are nonmissing
bysort occ3d2010 sector: egen emptycat = min(blankobs)
drop if (emptycat == 0) & (blankobs == 1)

save "$OESbuildtemp/oes_occ_sector.dta", replace

// COLLAPSE TO OCCUPATION-SECTOR LEVEL
use "$OESbuildtemp/oes_occ_sector.dta", clear
gen totemp = 1
collapse (sum) totemp (mean) meanwage (min) blankobs [fw=employment], by(sector occ3d2010)
drop if missing(sector)
replace totemp = 0 if blankobs == 1

* Save to .dta file
preserve
rename totemp nworkers_wt
drop blankobs
gen source = "OES"

save "$OESout/OESstats.dta", replace
restore

* Save to xlsx
bysort sector occupation: egen emp_occ_sector = total(totemp)
label variable emp_occ_sector "Total employment in occupation-sector pair"

bysort sector: egen emp_sector = total(totemp)
label variable emp_sector "Total employment in sector"

gen occshare_sector = emp_occ_sector / emp_sector
label variable occshare_sector "Occupation share within sector"

#delimit ;
export excel
	using "$OESout/oes_occ_sector.xlsx",
	replace firstrow(varlabels);
#delimit cr
