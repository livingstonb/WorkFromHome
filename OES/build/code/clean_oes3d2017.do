/* --- HEADER ---
This do-file cleans the OES dataset at the 3-digit occupation level.
*/

* Read raw data
import excel "build/input/nat3d2017", clear firstrow

* Clean
`#PREREQ' do "build/code/clean_oes_generic.do" 2017

// MERGE WITH SECTOR
rename naics naicscode
destring naicscode, replace
gen int ind3d = naicscode / 1000
gen int ind2d = floor(ind3d / 10)
gen int ind1d = floor(ind3d / 100)

`#PREREQ' local naicsdta "../industries/build/output/naicsindex2017.dta"

* 1-digit first
rename ind1d naics2017
#delimit ;
merge m:1 naics2017 using "`naicsdta'",
	keepusing(sector) keep(1 3 4) nogen update;
#delimit cr
rename naics2017 ind1d

* 2-digit
rename ind2d naics2017
#delimit ;
merge m:1 naics2017 using "`naicsdta'",
	keepusing(sector) keep(1 3 4) nogen update;
#delimit cr
rename naics2017 ind2d

* 3-digit
rename ind3d naics2017
#delimit ;
merge m:1 naics2017 using "`naicsdta'",
	keepusing(sector) keep(1 3 4) nogen update;
#delimit cr
rename naics2017 ind3d

rename a_mean meanwage
label variable meanwage "Mean annual wage"

rename a_median medianwage
label variable medianwage "Median annual wage"

rename tot_emp employment
label variable employment "Total employment rounded to nearest 10 (excl self-employed)"

rename pct_total occshare_industry
label variable occshare_industry "% of industry employment in given occ, provided"

* Save
`#TARGET' local outpath "build/output/oes3d_cleaned.dta"
save "`outpath'", replace