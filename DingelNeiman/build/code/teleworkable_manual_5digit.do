/* --- HEADER ---
This script reads the teleworkable measure constructed by
Dingel and Neiman, and aggregates occupations to the 5-digit level.
*/

// Prepare OES 5-digit occs for merge
`#PREREQ' use "build/temp/nat3d2017.dta", clear

* Collapse by sector and detailed occupation
rename occ_code soc2010
rename tot_emp employment
rename a_mean meanwage

keep if occ_group == "broad"

gen soc5d2010 = strtrim(soc2010)
replace soc5d2010 = subinstr(soc5d2010, "-", "", .)
destring soc5d2010, force replace
replace soc5d2010 = soc5d2010 / 10

drop if soc5d2010 >= 55000
drop if missing(sector)

preserve
tempfile bysector
collapse (sum) employment (mean) meanwage, by(sector soc5d2010)
save `bysector'
restore

collapse (sum) employment (mean) meanwage, by(soc5d2010)
append using `bysector'
replace sector = 2 if missing(sector)
label define sector_lbl 2 "Pooled", modify

tempfile oesdata
save `oesdata'

// Read teleworkable
clear
`#PREREQ' import delimited using "build/input/teleworkable_opinion_edited.csv", varnames(1)

rename broadgroupcode soc5d2010
rename broadgroup occtitle

replace occtitle = strtrim(occtitle)

replace soc5d2010 = strtrim(soc5d2010)
replace soc5d2010 = subinstr(soc5d2010, "-", "", .)
destring soc5d2010, force replace
replace soc5d2010 = soc5d2010 / 10

`#PREREQ' do "../occupations/build/output/soc5dlabels2010.do"
label values soc5d2010 soc5d2010_lbl

drop occtitle

* Recode non-binary values for teleworkable
recode teleworkable (0.25 = 0) (0.75 = 1)

// Merge with OES
merge 1:m soc5d2010 using `oesdata', nogen keep(1 3)
drop if missing(sector)

`#TARGET' save "build/output/DN_5d_manual_scores.dta", replace
