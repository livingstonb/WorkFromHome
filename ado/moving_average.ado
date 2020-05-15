program moving_average
	
	syntax varlist , time(varlist) panelid(varlist) gen(name) [nperiods(integer 5)]
	
	tsset `panelid' `time'
	gen `gen' = .

	tempvar tvar
	by `panelid': gen `tvar' = _n
	
	quietly sum `tvar'
	local tf = `r(max)'
	
	local t1 = 1
	local t2 = `nperiods'
	while (`t2' <= `tf') {
		tempvar tmp_mean
		by `panelid': egen `tmp_mean' = mean(`varlist') if inrange(`tvar', `t1', `t2')
		by `panelid': replace `gen' = `tmp_mean' if `tvar' == floor((`t2'+`t1') / 2)
		drop `tmp_mean'
		
		local ++t1
		local ++t2
	}
end
