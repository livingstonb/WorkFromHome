adopath + "ado"

capture mkdir "stats/output/figs"

args make_plots

local state_specific_policies = 0

forvalues fd = 1/1 {

	local ii = 0
	local type = cond(`fd', "FD", "levels")
	local FD = cond(`fd', "D.", "")
	local suffix = "work"
	
	local model_titles
	
	local weight_vals 0 1
	local nat_vals 0 1 
	local state_vals 1 0
	local quad_vals 0
	
	* POLICY DUMMIES
	local dt = cond(`fd', "", "ge_")
	local policyvars `FD'd_school_closure `FD'd_dine_in_ban `FD'd_non_essential_closure `FD'd_shelter_in_place
	
	if `state_specific_policies' {
		local tmp_policyvars `policyvars'
		local policyvars
		foreach var of local tmp_policyvars {
			local policyvars `policyvars' i.stateid#c.`var'
		}
	}

	foreach popweight of local weight_vals {
	foreach natl of local nat_vals {
	foreach state of local state_vals {
	foreach quadratic of local quad_vals {
	
		if `natl' + `state' == 0 {
			continue
		}
		local ++ii
		
		capture mkdir "stats/output/logs"
		capture log close reg_log
		log using "stats/output/logs/work_`type'_M`ii'.txt", name(reg_log) text replace
		
		#delimit ;
		regmobility, fd(`fd') natl(`natl') state(`state') quad(`quadratic')
			suffix("`suffix'") estnum(`ii') popwgt(`popweight')
			policyvars("`policyvars'");
		#delimit cr
		
		log close reg_log

		if "`make_plots'" == "make_plots" {
			local states = `" "California" "Georgia" "New Mexico" "New York" "Pennsylvania" "West Virginia" "'
			foreach state in `states' {
				plt_fitted `state', suffix("`suffix'") savedir("stats/output/figs/`suffix'_`type'_M`ii'") fd(`fd')
			}
		}
		
		
		local mtitle = cond(`popweight', "Wtd", "Unwtd")
		
		if `ii' == 1 {
			local model_titles `"`mtitle'"'
		}
		else {
			local model_titles `"`model_titles'"' `"`mtitle'"'
		}
	}
	}
	}
	}
	
	local figtitle = cond("`suffix'"=="work", "Workplaces", "Retail and rec")
	
	if `state_specific_policies' {
		local policyvars
	}
	
	* LATEX table creation
	#delimit ;
	esttab using "stats/output/`type'_mobility_`suffix'_regressions.tex", 
			replace label compress booktabs not
			keep(``FD''cases ``FD''natl_cases
			`policyvars')
			r2 ar2 scalars(N)
			mtitles(`"`model_titles'"')
			title("`figtitle', `type'");
	#delimit cr
}

// * First differences
//
// local mobvars work
// tsset stateid date
// forvalues fd = 0/1 {
// foreach suffix of local mobvars {
// 	estimates clear
// 	local ii = 0
//	
// 	if `fd' {
// 		local prefix "D."
// 		local type "FD"
// 		local policies_for_table d_school_closure d_dine_in_ban d_non_essential_closure
// 		local march_var d_march13
// 	}
// 	else {
// 		local prefix
// 		local type "levels"
// 		local policies_for_table d_ge_school_closure d_ge_dine_in_ban d_ge_non_essential_closure
// 		local march_var d_ge_march13
// 	}
//	
// 	if `state_specific_policies' {
// 		local policies_for_table
// 	}
//	
// 	local timevar = "i.stateid#c.`march_var'"
//	
// 	* For tex output
// 	local model_titles
//	
// 	* Loop over regressions
// 	forvalues popweight = 0/1 {
// 	forvalues natl = 0/1 {
// 	forvalues quadratic = 0/1 {
// 		local ++ii		
//
// 		local wgt_expr = cond(`popweight', "popwgt(wgt)", "")
//		
// 		capture mkdir "stats/output/logs"
//
// 		log using "stats/output/logs/`suffix'_`type'_M`ii'.txt", name(reg_log) text replace
//		
// 		#delimit ;
// 		regmobility, fd(`fd') natl(`natl') quad(`quadratic') timetrend(`timevar')
// 			suffix(`suffix') estname("EST`ii'") `wgt_expr'
// 			statepolicies(`state_specific_policies');
// 		#delimit cr
//		
// 		log close reg_log
//
// 		if "`make_plots'" == "make_plots" {
// 			local states = `" "California" "Georgia" "New Mexico" "New York" "Pennsylvania" "West Virginia" "'
// 			foreach state in `states' {
// 				plt_fitted `state', suffix("`suffix'") savedir("stats/output/figs/`suffix'_`type'_M`ii'") fd(`fd')
// 			}
// 		}
//		
//		
// 		local mtitle = cond(`popweight', "Wtd", "Unwtd")
//		
// 		if `ii' == 1 {
// 			local model_titles `"`mtitle'"'
// 		}
// 		else {
// 			local model_titles `"`model_titles'"' `"`mtitle'"'
// 		}
// 	}
// 	}
// 	}
// 	}
//	
// 	local figtitle = cond("`suffix'"=="work", "Workplaces", "Retail and rec")
//		
// 	label variable mobility_`suffix' "Mobility"
// 	#delimit ;
// 	esttab using "stats/output/`type'_mobility_`suffix'_regressions.tex", 
// 			replace label compress booktabs not
// 			keep(`prefix'cases `prefix'sq_cases `prefix'natl_cases `prefix'sq_natl_cases
// 			`policies_for_table'
// 			d_shelter_in_place)
// 			r2 ar2 scalars(N)
// 			mtitles(`"`model_titles'"')
// 			title("`figtitle', `type'");
// 	#delimit cr
// }
// }
