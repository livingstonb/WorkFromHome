
use "$OESout/oes_cleaned.dta", clear

* Housekeeping
keep if OCC_GROUP == "minor"

rename soc3d2010 occ3d2010
#delimit ;
keep NAICS NAICS_TITLE occ3d2010 OCC_GROUP
	employment occshare_industry
	meanwage medianwage sector;
#delimit cr

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
	use soc3d2010 using "$WFHshared/occupations/output/occindex2010.dta", clear
	gen sector = `sval'
	gen employment = 1
	gen blankobs = 1
	
	rename soc3d2010 occ3d2010
	
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

* Collapse
gen totemp = 1
collapse (sum) totemp (mean) meanwage (min) blankobs [fw=employment], by(sector occ3d2010)
drop if missing(sector)
replace totemp = 0 if blankobs == 1

* Save to .dta file
preserve
rename totemp nworkers_wt
drop blankobs
gen source = "OES"

save "$OESstatsout/OESstats.dta", replace
restore

* Save to xlsx
bysort sector occ3d2010: egen emp_occ_sector = total(totemp)
label variable emp_occ_sector "Total employment in occupation-sector pair"

bysort sector: egen emp_sector = total(totemp)
label variable emp_sector "Total employment in sector"

gen occshare_sector = emp_occ_sector / emp_sector
label variable occshare_sector "Occupation share within sector"

#delimit ;
export excel
	using "$OESstatsout/oes_occ_sector.xlsx",
	replace firstrow(varlabels);
#delimit cr
