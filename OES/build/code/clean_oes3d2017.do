/* --- HEADER ---
This do-file cleans the OES dataset at the 3-digit occupation level.
*/

* Read raw data
import excel "build/input/nat3d2017", clear firstrow

* Clean
`#PREREQ' do "build/code/clean_oes_generic.do" 2017 1

// MERGE WITH SECTOR
`#PREREQ' `"../industries/build/output/naicsindex2017.dta"'
`#PREREQ' do "build/code/merge_with_sector.do"

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