
estimates clear



* Benchmark
local policyvars d_dine_in_ban d_school_closure d_non_essential_closure d_shelter_in_place
#delimit ;
eststo: reg mobility_work cases `policyvars' if restr_sample, vce(cluster stateid);
#delimit cr

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
		addnotes("Pop-weighted mean of peak cases = `mean_max_cases'"
		"Pop-weighted mean of $(\text{peak cases}) ^ {0.25}$ = `mean_max_cases_pow1'"
		"Pop-weighted mean of $(\text{peak cases}) ^ {0.5}$ = `mean_max_cases_pow2'"
		"Pop-weighted mean of $(\text{peak cases}) ^ {0.75}$ = `mean_max_cases_pow3'")
		keep(cases pow_cases1 pow_cases2 pow_cases3
		d_school_closure Ld_school_closure Fd_school_closure
		d_dine_in_ban Ld_dine_in_ban Fd_dine_in_ban
		d_non_essential_closure Ld_non_essential_closure Fd_non_essential_closure
		d_shelter_in_place Fd_shelter_in_place)
		r2 ar2 scalars(N)
		mtitles(`"`mtitles'"')
		title("Workplaces, levels");
#delimit cr
