adopath + "ado"

* Use state-specific coefficients on all policy dummies
local state_specific_policies = 0


#delimit ;
local policyvars d_school_closure d_dine_in_ban
	d_non_essential_closure d_shelter_in_place;
#delimit cr

#delimit ;
local st_policyvars i.stateid#c.d_school_closure i.stateid#c.d_dine_in_ban
	i.stateid#c.d_non_essential_closure i.stateid#c.d_shelter_in_place;
#delimit cr

// TABLE 1 - WORKPLACES, LEVELS

* Simplest model
eststo: reg mobility_work `policyvars' d_dow*, vce(cluster stateid)

* Add cases, unadjusted for recoveries
eststo: reg mobility_work raw_cases `policyvars' d_dow*, vce(cluster stateid)

* Use adjusted cases
eststo: reg mobility_work cases `policyvars' d_dow*, vce(cluster stateid)

* Add national cases
eststo: reg mobility_work cases natl_cases `policyvars' d_dow*, vce(cluster stateid)

* Use state-specific coefficients on weekend dummies
eststo: reg mobility_work cases `st_policyvars' d_dow*, vce(cluster stateid)

* Loop over tables
forvalues fd = 0/0 {
	
	local type = cond(`fd', "FD", "levels")
	local FD = cond(`fd', "D.", "")
	local suffix = "work"
	
	* Policy dummies
	local ST = cond(`state_specific_policies', "i.stateid#c.", "")
	
	#delimit ;
	local policyvars `ST'`FD'd_school_closure `ST'`FD'd_dine_in_ban
		`ST'`FD'd_non_essential_closure `ST'`FD'd_shelter_in_place;
	#delimit cr
	
	* Prepare loop over other options
	local nloop		3
	local weight_vals	0 0 0
	local nat_vals 		0 0 0
	local state_vals	0 1 1
	local stdiff_vals	0 0 0
	local quad_vals		0 0 0
	local fullsample_vals	0 0 0
	local stdow_vals	0 0 1
	
	* Macro to store model titles
	local model_titles
	
	* Loop over options
	forvalues ii = 1/`nloop' {
		local popwgt: word `ii' of `weight_vals'
		local natl: word `ii' of `nat_vals'
		local state: word `ii' of `state_vals'
		local state_diff: word `ii' of `stdiff_vals'
		local quad: word `ii' of `quad_vals'
		local fullsample: word `ii' of `fullsample_vals'
		local stdow: word `ii' of `stdow_vals'
		
		* Log to store full regression results
		capture mkdir "stats/output/logs"
		capture log close reg_log
		log using "stats/output/logs/work_`type'_alt_M`ii'.txt", name(reg_log) text replace
		
		* Regression
		#delimit ;
		regmobility, fd(`fd') natl(`natl') state(`state') quad(`quad')
			suffix("`suffix'") estnum(`ii') popwgt(`popwgt') stdiff(`state_diff')
			policyvars("`policyvars'") fullsample(`fullsample')
			stdow(`stdow');
		#delimit cr
		log close reg_log

		* Update model titles with Wtd or Unwtd label
		local mtitle = cond(`popwgt', "Wtd", "Unwtd")
		if `ii' == 1 {
			local model_titles `"`mtitle'"'
		}
		else {
			local model_titles `"`model_titles'"' `"`mtitle'"'
		}
	}
	
	* LATEX table creation
	local figtitle = cond("`suffix'"=="work", "Workplaces", "Retail and rec")
	
	if `state_specific_policies' {
		local policyvars
	}

	#delimit ;
	esttab using "stats/output/`type'_mobility_`suffix'_alt_regressions.tex", 
			replace label compress booktabs not
			keep(`FD'cases `FD'sq_cases
			`policyvars')
			r2 ar2 scalars(N)
			mtitles(`"`model_titles'"')
			title("`figtitle', `type'");
	#delimit cr
}
