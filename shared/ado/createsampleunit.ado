program createsampleunit
	#delimit ;
	syntax newvarname
		[, PANELID(varname)]
		[, DYNAMICVARS(varlist)]
		[, STATICVARS(varlist)];
	#delimit cr
	
	quietly sum `panelid'
	local tmin = `r(min)'
	local tmax = `r(min)'
	
	
end
