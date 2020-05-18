adopath + "ado"

capture mkdir "stats/output/figs"

args make_plots

* Use state-specific coefficients on all policy dummies
local state_specific_policies = 0

* Use state-specific coefficients on day-of-week dummies
local state_specific_dow = 1

* Loop over tables
forvalues fd = 0/0 {

	
	local type = cond(`fd', "FD", "levels")
	local FD = cond(`fd', "D.", "")
	local suffix = "work"
	
	* Policy dummies
	local ST = cond(`state_specific_policies', "i.stateid#c.", "")
	
// 	#delimit ;
// 	local policyvars `ST'`FD'd_school_closure `ST'`FD'd_dine_in_ban
// 		`ST'`FD'd_non_essential_closure `ST'`FD'd_shelter_in_place
// 		`ST'`FD'LD.d_school_closure `ST'`FD'LD.d_dine_in_ban
// 		`ST'`FD'LD.d_non_essential_closure
// 		`ST'`FD'FD.d_school_closure `ST'`FD'FD.d_dine_in_ban
// 		`ST'`FD'FD.d_non_essential_closure `ST'`FD'FD.d_shelter_in_place;
// 	#delimit cr

	#delimit ;
	local policyvars `ST'`FD'd_school_closure `ST'`FD'd_dine_in_ban
		`ST'`FD'd_non_essential_closure `ST'`FD'd_shelter_in_place;
	#delimit cr
//	
	* Prepare loop over other options
	local nloop		1
	local weight_vals	0 0 0
	local nat_vals 		0 0 0
	local state_vals	1 1 0
	local stdiff_vals	0 0 0
	local quad_vals		0 0 0
	local exp_vals		0 1 0
	local march_vals	0 0 1

	* Macro to store model titles
	local model_titles
	
	* Loop over options
	forvalues ii = 1/`nloop' {
		local popwgt: word `ii' of `weight_vals'
		local natl: word `ii' of `nat_vals'
		local state: word `ii' of `state_vals'
		local quad: word `ii' of `quad_vals'
		local state_diff: word `ii' of `stdiff_vals'
		
		* Log to store full regression results
		capture mkdir "stats/output/logs"
		capture log close reg_log
		log using "stats/output/logs/work_`type'_M`ii'.txt", name(reg_log) text replace
		
		* Regression
		#delimit ;
		regmobility, fd(`fd') natl(`natl') state(`state') quad(`quad')
			suffix("`suffix'") estnum(`ii') popwgt(`popwgt') stdiff(`state_diff')
			policyvars("`policyvars'") stdow(`state_specific_dow');
		#delimit cr
		log close reg_log

		if "`make_plots'" == "make_plots" {
			local states = `" "California" "Georgia" "New Mexico" "New York" "Pennsylvania" "West Virginia" "'
			foreach state in `states' {
				plt_fitted `state', suffix("`suffix'") savedir("stats/output/figs/`suffix'_`type'_M`ii'") fd(`fd')
			}
		}
		
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
	esttab using "stats/output/`type'_mobility_`suffix'_regressions.tex", 
			replace label compress booktabs not
			keep(`FD'cases)
			r2 ar2 scalars(N)
			mtitles(`"`model_titles'"')
			title("`figtitle', `type'");
	#delimit cr
}