/* --- HEADER ---
Merges teleworkable and SIPP variables at the 5-digit occupation level.
*/

adopath + "../ado"
adopath + "ado"

`#PREREQ' use "../SIPP/stats/output/SIPPwfh_5digit.dta", clear
rename occ5d2010 soc5d2010
drop nworkers_wt meanwage source

`#PREREQ' local telew "../DingelNeiman/build/output/DN_5d_manual_scores.dta"
merge 1:1 soc5d2010 sector using "`telew'", nogen

`#PREREQ' local occs "../occupations/build/output/census2010_to_soc2010.dta"
appendblanks soc5d2010 using "`occs'", over1(sector) values1(0 1)

bysort soc5d2010 sector: egen ismissing = min(blankobs)
drop if blankobs & !ismissing
drop if missing(soc5d2010, sector)
drop ismissing blankobs

* Combine teleworkable and OES variables where SIPP occupations are combined
#delimit ;
combine_5d_teleworkable soc5d2010, socval(25100) televal(1)
	label("Postsecondary Teachers");
#delimit cr

#delimit ;
combine_5d_teleworkable soc5d2010, socval(25300) televal(1)
	label("Other Teachers and Instructors");
#delimit cr

#delimit ;
combine_5d_teleworkable soc5d2010, socval(53100) televal(0)
	label("Supervisors of Transportation and Material Moving Workers");
#delimit cr

#delimit ;
combine_5d_teleworkable soc5d2010, socval(29900) televal(0)
	label("Occupational Health and Safety Specialists and Technicians");
#delimit cr

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
local rstubs n_sipp pct_workfromhome mean_* qualitative_h2m foodinsecure
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

`#TARGET' save "build/output/merged5d.dta", replace
