/*
This do-file computes employment and wage statistics by 3-digit
occupation from OES data.
*/

clear

// PREPARE BLANK OCCUPATION ENTRIES
local occ2010dta "../occupations/build/output/census2010_to_soc2010.dta"
tempfile yrtmp
save `yrtmp', emptyok
forvalues sval = 0/1 {
	use soc3d2010 using "`occ2010dta'", clear
	gen sector = `sval'
	gen employment = 1
	gen blankobs = 1
	
	rename soc3d2010 occ3d2010
	
	append using `yrtmp'
	save `yrtmp', replace
}

// READ OES DATA
* Read raw data
import excel "build/input/nat3d2017", clear firstrow

* Clean
do "build/code/clean_oes_generic.do" 2017 1
keep if minor_level

// MERGE WITH SECTOR
do "build/code/merge_with_sector.do"

rename a_mean meanwage
label variable meanwage "Mean annual wage"

rename a_median medianwage
label variable medianwage "Median annual wage"

rename tot_emp employment
label variable employment "Total employment rounded to nearest 10 (excl self-employed)"

rename pct_total occshare_industry
label variable occshare_industry "% of industry employment in given occ, provided"

* Housekeeping
rename soc3d2010 occ3d2010
#delimit ;
keep occ3d2010 occ_group
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

save "stats/output/OESstats.dta", replace
restore

* Save to xlsx
local xlxpath "stats/output/oes_occ_sector.xlsx"
export excel using "`xlxpath'", replace firstrow(varlabels)
