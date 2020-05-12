/*
Reshapes merged dataset into wide format.
*/

adopath + "../ado"
use "build/temp/merged3d.dta", clear

tostring sector, replace force
tostring source, replace force
gen col = "_d" + source + "s" + sector

rename median_netliq_earnings_ratio median_nla_earnratio

#delimit ;
local variables oes* pct_* mean* median* nla*
	foodinsecure* qualitative_h2m* teleworkable whtm* phtm*;
#delimit cr

keep occ3d2010 col `variables'
varlabels, save
reshape wide `variables', i(occ3d2010) j(col) string
varlabels, restore

foreach var of varlist * {
	quietly count if !missing(`var')
	if `r(N)' == 0 {
		drop `var'
	}
}
rename oes_employment_d1s0 oes_employment_s0
rename oes_employment_d1s1 oes_employment_s1
rename oes_meanwage_d1s0 oes_meanwage_s0
rename oes_meanwage_d1s1 oes_meanwage_s1
rename oes_occshare_d1s0 oes_occshare_s0
rename oes_occshare_d1s1 oes_occshare_s1
drop oes_employment_d* oes_meanwage_d* oes_occshare_d*

foreach var of varlist *s0 {
	local lab: variable label `var'
	label variable `var' "`lab', sector C"
}
foreach var of varlist *s1 {
	local lab: variable label `var'
	label variable `var' "`lab', sector S"
}

foreach var of varlist *d1s* {
	local lab: variable label `var'
	label variable `var' "`lab', ACS2013to2017"
}
foreach var of varlist *d2s* {
	local lab: variable label `var'
	label variable `var' "`lab', ACS2015to2017"
}
foreach var of varlist *d3s* {
	local lab: variable label `var'
	label variable `var' "`lab', ACS2017only"
}
foreach var of varlist *d4s* {
	local lab: variable label `var'
	label variable `var' "`lab', ATUS"
}
foreach var of varlist *d5s* {
	local lab: variable label `var'
	label variable `var' "`lab', DingelNeiman"
}
foreach var of varlist *d6s* {
	local lab: variable label `var'
	label variable `var' "`lab', SIPP"
}

order occ3d2010 oes*

* Merge in essential workers data
local ess "../industries/stats/output/essential_share_by_occ3d.dta"
rename occ3d2010 soc3d2010
merge 1:1 soc3d2010 using "`ess'", nogen keep(1 3) keepusing(essential)
rename soc3d2010 occ3d2010

label variable essential "Share of workers in essential industries"

save "build/output/merged3d.dta", replace
