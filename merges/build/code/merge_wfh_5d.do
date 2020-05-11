/* --- HEADER ---
Merges teleworkable and SIPP variables at the 5-digit occupation level.
*/

args sunit

adopath + "../ado"
adopath + "ado"

`#PREREQ' use "../SIPP/stats/output/SIPP5d_`sunit'.dta", clear
rename occ5d2010 soc5d2010
drop nworkers_wt meanwage source

`#PREREQ' local telew "../DingelNeiman/build/output/DN_5d_manual_scores.dta"
merge 1:1 soc5d2010 sector using "`telew'", nogen

* Add blanks
`#PREREQ' local blanks "../occupations/build/output/soc5dvalues2010.dta"
appendblanks soc5d2010 using "`blanks'", over1(sector) values1(0 1 2)

* Drop missing sector or occupation
drop if missing(soc5d2010, sector)

* Critical workers by occupation
`#PREREQ' local critical "../CriticalInfrastructure/build/output/critical5d.dta"
merge m:1 soc5d2010 using "`critical'", nogen keepusing(val_critical)
gen critical = val_critical if sector == 2
drop val_critical
label variable critical "Critical occupation indicator"

* Essential workers by occupation
`#PREREQ' local essential "../industries/build/output/essential_share_by_occ5d.dta"
merge m:1 soc5d2010 using "`essential'", nogen keepusing(essential)
replace essential = . if inlist(sector, 0, 1)
label variable essential "Share of workers in essential industries"

* Aggregate variables where SIPP occupations are combined
#delimit ;
combine_5d_teleworkable soc5d2010, socval(25100) televal(1)
	label("Postsecondary Teachers");
combine_5d_teleworkable soc5d2010, socval(25300) televal(1)
	label("Other Teachers and Instructors");
combine_5d_teleworkable soc5d2010, socval(53100) televal(0)
	label("Supervisors of Transportation and Material Moving Workers");
combine_5d_teleworkable soc5d2010, socval(29900) televal(0)
	label("Occupational Health and Safety Specialists and Technicians");
#delimit cr

* Variables critical and essential need to be constant across sectors, for reshape
foreach var of varlist critical essential {
	rename `var' tmp_`var'
	bysort soc5d2010 (sector): gen `var' = tmp_`var'[_N]
	drop tmp_`var'
}

* Make sure all sunit values are present
if "`sunit'" == "person" {
	replace sunit = 0 if missing(sunit)
}
else if "`sunit'" == "fam" {
	replace sunit = 1 if missing(sunit)
}
else if "`sunit'" == "hh" {
	replace sunit = 2 if missing(sunit)
}

* Drop small groups not showing up in SIPP and not having data for both sectors
bysort soc5d2010: gen counts = _N
drop if (counts != 3)
drop counts 

* Cleanup and reshape wide
rename nworkers_unw n_sipp

label variable n_sipp "SIPP num obs"
label variable employment "OES Total Employment"
label variable meanwage "OES Mean Annual Wage"

#delimit ;
local rstubs n_sipp pct_workfromhome mean_* qualitative_h2m foodinsecure weights
	nla_lt* whtm_* phtm_* htm_* median_* teleworkable employment meanwage;
#delimit cr

local stubs
foreach var of local rstubs {
	rename `var' `var'_s
	local stubs `stubs' `var'_s
}
varlabels, save

quietly reshape wide `stubs', i(soc5d2010) j(sector)
varlabels, restore

foreach var of varlist *_s0 {
	local lab: variable label `var'
	label variable `var' "`lab', sector C"
}

foreach var of varlist *_s1 {
	local lab: variable label `var'
	label variable `var' "`lab', sector S"
}

foreach var of varlist *_s2 {
	local lab: variable label `var'
	label variable `var' "`lab', both sectors"
}
sort soc5d2010
label variable soc5d2010 "Occupation"

egen telefinal = rowfirst(teleworkable_s*)
drop teleworkable_s*
rename telefinal teleworkable
label variable teleworkable "Teleworkable, manual score"

* Add 2- and 3-digit codes
gen soc2d2010 = floor(soc5d2010 / 1000)
label variable soc2d2010 "Occupation, 2-digit"
`#PREREQ' do "../occupations/build/output/soc2dlabels2010.do"
label values soc2d2010 soc2d2010_lbl

gen soc3d2010 = floor(soc5d2010 / 100)
label variable soc3d2010 "Occupation, 3-digit"
`#PREREQ' do "../occupations/build/output/soc3dlabels2010.do"
label values soc3d2010 soc3d2010_lbl

order soc2d2010 soc3d2010 soc5d2010
drop blankobs

`#TARGET' save "build/output/merged5d_`sunit'.dta", replace
