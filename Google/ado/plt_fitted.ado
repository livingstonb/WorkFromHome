* Plot fitted vs actual for states with few/many infections

program plt_fitted
	
	syntax [anything], [SUFFIX(string)] [SAVEDIR(string)] [FD(integer 0)]
	
	local state "`anything'"

	tempvar yhat
	predict `yhat', xb
	
	if `fd' {
		* Generated fitted levels
		tempvar tmp_levels fitted_levels
		gen `tmp_levels' = `yhat'
		replace `tmp_levels' = mobility_`suffix' if date == date("2020-02-24", "YMD")
		by stateid (date): gen `fitted_levels' = sum(`tmp_levels')
	}
	else {
		tempvar fitted_levels
		gen `fitted_levels' = `yhat'
	}
	
	if "`suffix'" == "work" {
		label variable `fitted_levels' "Fitted log mobility, workplaces"
	}
	else {
		label variable `fitted_levels' "Fitted log mobility, retail and rec"
	}

	quietly sum cases if statename == "`state'"
	local num_cases = `r(max)' - `r(min)'
	local num_cases: di %7.5g `=`num_cases''

	#delimit ;
	twoway line mobility_`suffix' date if statename == "`state'"
		|| line `fitted_levels' date if statename == "`state'",
		graphregion(color(gs16)) title("`state', cases/cap = `num_cases'");
	#delimit cr
	
	if "`savedir'" != "" {
		capture mkdir "`savedir'"
		graph export "`savedir'/`state'.png", replace
		graph close
	}
end
