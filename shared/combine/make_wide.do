
use "shared/combine/merged_4_9_20.dta", clear

tostring sector, replace force
tostring source, replace force
gen col = "_d" + source + "s" + sector

rename median_netliq_earnings_ratio median_nla_earnratio
local variables oes* pct_* mean* median* nla* foodinsecure* qualitative_h2m* teleworkable whtm* phtm*


keep occ3d2010 col `variables'
reshape wide `variables', i(occ3d2010) j(col) string

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

order occ3d2010 oes*

save "shared/combine/merged_4_9_20_wide4.dta", replace
