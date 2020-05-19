
estimates clear



// * Benchmark
// local policyvars d_dine_in_ban d_school_closure d_non_essential_closure d_shelter_in_place
// #delimit ;
// eststo: reg mobility_work cases `policyvars' if restr_sample, vce(cluster stateid);
// #delimit cr

local mtitles `"Benchmark"'

// * Including state cases
// local policyvars d_dine_in_ban d_school_closure d_non_essential_closure d_shelter_in_place
// #delimit ;
// eststo: reg mobility_work cases state_cases `policyvars' if restr_sample, vce(cluster stateid);
// #delimit cr
//
// * Leads and lags
// local policyvars d_dine_in_ban d_school_closure d_non_essential_closure d_shelter_in_place
// #delimit ;
// eststo: reg mobility_work cases `policyvars'
// 	 Ld_dine_in_ban Ld_school_closure Ld_non_essential_closure
// 	 Fd_dine_in_ban Fd_school_closure Fd_non_essential_closure
// 	 Fd_shelter_in_place if restr_sample, vce(cluster stateid);
// #delimit cr

* Cases at different powers
local policyvars d_dine_in_ban d_school_closure d_non_essential_closure d_shelter_in_place

#delimit ;
local aug_policyvars `policyvars' Fd_shelter_in_place
	Ld_dine_in_ban Ld_school_closure Ld_non_essential_closure
	Fd_dine_in_ban Fd_school_closure Fd_non_essential_closure;
#delimit cr

capture drop pow_cases*

local powers 0.25 0.5 0.75
forvalues lead_lag = 0/1 {
local ii = 1
foreach pow of local powers {
	capture gen pow_cases`ii' = cases ^ `pow'
	label variable pow_cases`ii' "County cases p.c. raised to `pow'"
	
	local pdummies = cond(`lead_lag', "`aug_policyvars'", "`policyvars'")
	
	#delimit ;
	eststo: reg mobility_work pow_cases`ii' `pdummies' if restr_sample, vce(cluster stateid);
	#delimit cr
	local ++ii
	
	local title1 = "alpha = `pow'"
	local title2 = cond(`lead_lag', ", lead/lag", "")
	local mtitles `"`mtitles'"' `"`title1'`title2'"'
}
}

* Loop over weights and alpha
estimates clear

local lags 1

local policyvars d_dine_in_ban d_school_closure d_non_essential_closure d_shelter_in_place
if `lags' {
	#delimit ;
	local policyvars `policyvars' Fd_shelter_in_place
		Ld_dine_in_ban Ld_school_closure Ld_non_essential_closure
		Fd_dine_in_ban Fd_school_closure Fd_non_essential_closure;
	#delimit cr
}

local alphas 0.8 0.9 1

capture gen adj_cases100 = cases
capture gen wgts = population / 10000

local ii = 0
forvalues usewgts = 0/1 {
foreach alpha of local alphas {
	local ++ii

	local suff = "`=round(`alpha' * 100)'"
	local recovery = 1 - `alpha'
	capture gen pow_cases`suff' = adj_cases`suff' ^ 0.25
	label variable pow_cases`suff' "$\text{Cases}^{0.25}$, recov = `recovery'"
	
	local wgt_macro = cond(`usewgts', "[aw=wgts]", "")
	
	eststo: reg mobility_work pow_cases`suff' `policyvars' if restr_sample `wgt_macro', vce(cluster stateid)
	
	local title1 = "recov = `recovery'"
	local title2 = cond(`usewgts', ", wtd", "")
	local title = "`title1'`title2'"
	
	if `ii' == 1 {
		local mtitles `"`title'"'
	}
	else {
		local mtitles `"`mtitles'"' `"`title'"'
	}
}
}

local regnum = cond(`lags', 2, 1)

local regtitle = "Recovery rate and population weights"
local regtitle = cond(`lags', "`regtitle', leads and lags", "`regtitle'")

#delimit ;
esttab using "stats/output/county_regressions`regnum'.tex", 
		replace label compress booktabs not
		keep(pow_cases80 pow_cases90 pow_cases100
		`policyvars')
		r2 ar2 scalars(N)
		mtitles(`"`mtitles'"')
		title("`regtitle'");
#delimit cr

* Mean cases values
preserve

collapse (max) cases (firstnm) population if restr_sample, by(ctyid)
sum cases [aw=population]
local mean_max_cases = r(mean)

local powers 0.25 0.5 0.75
local ii = 1
foreach pow of local powers {
	gen tmp_pow_cases`ii' = cases ^ `pow'
	sum tmp_pow_cases`ii' [aw=population]
	local mean_max_cases_pow`ii' = r(mean)
	local ++ii
}
drop tmp_pow_cases*

restore

* LATEX table creation
#delimit ;
esttab using "stats/output/county_regressions.tex", 
		replace label compress booktabs not
		keep(cases pow_cases80 pow_cases90 pow_cases100
		d_school_closure Ld_school_closure Fd_school_closure
		d_dine_in_ban Ld_dine_in_ban Fd_dine_in_ban
		d_non_essential_closure Ld_non_essential_closure Fd_non_essential_closure
		d_shelter_in_place Fd_shelter_in_place)
		r2 ar2 scalars(N)
		mtitles(`"`mtitles'"')
		title("Workplaces, levels");
#delimit cr







* NL
capture gen wgts = population / 10000

gen nl_sample = restr_sample & !missing(d_dine_in_ban, d_school_closure, d_non_essential_closure, d_shelter_in_place, cases, mobility_work)
local policyvars d_dine_in_ban d_school_closure d_non_essential_closure d_shelter_in_place
local linear xb: `policyvars'
nl (mobility_work = {b0=-1} * adj_cases90 ^ {b1=0.25} + {`linear'}) if nl_sample, vce(cluster stateid)
