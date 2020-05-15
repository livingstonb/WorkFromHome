adopath + "ado"

capture mkdir "stats/output/figs"

args make_plots

local state_specific_policies = 0

local mobvars work
tsset stateid date
forvalues fd = 0/1 {
foreach suffix of local mobvars {
	estimates clear
	local ii = 0
	
	if `fd' {
		local prefix "D."
		local type "FD"
		local policies d_school_closure d_dine_in_ban d_non_essential_closure
		local march_var d_march13
	}
	else {
		local prefix
		local type "levels"
		local policies d_ge_school_closure d_ge_dine_in_ban d_ge_non_essential_closure
		local march_var d_ge_march13
	}
	
	if `state_specific_policies' {
		local policies
	}
	
	* For tex output
	local timevar
	local model_titles
	
	* Loop over regressions
	forvalues popweight = 0/1 {
	forvalues natl = 0/1 {
	forvalues quadratic = 0/1 {
	forvalues timetrend = 1/1 {
		local ++ii
		
		if `timetrend' {
			local dt = cond(`fd', "ge_", "")
			local timevar = "i.stateid#c.`march_var'"
		}
		else {
			local timevar
		}
		
		if `popweight' {
			local wgt_expr popwgt(wgt)
		}
		else {
			local wgt_expr
		}
		
		capture mkdir "stats/output/logs"

		log using "stats/output/logs/`suffix'_`type'_M`ii'.txt", name(reg_log) text replace
		
		#delimit ;
		regmobility, fd(`fd') natl(`natl') quad(`quadratic') timetrend(`timevar')
			suffix(`suffix') estname("EST`ii'") `wgt_expr'
			statepolicies(`state_specific_policies');
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
		
	label variable mobility_`suffix' "Mobility"
	#delimit ;
	esttab using "stats/output/`type'_mobility_`suffix'_regressions.tex", 
			replace label compress booktabs not
			keep(`prefix'cases `prefix'sq_cases `prefix'natl_cases `prefix'sq_natl_cases
			`time_trend_var'
			`policies'
			d_shelter_in_place)
			r2 ar2 scalars(N)
			mtitles(`"`model_titles'"')
			title("`figtitle', `type'");
	#delimit cr
}
}
