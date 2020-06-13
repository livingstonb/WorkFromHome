program iter_ols, rclass

	args xvar exponent

	tempvar transformed
	gen `transformed' = (0.0676 * `xvar') ^ `exponent'

	#delimit ;
	quietly reg mobility_work `xvar' `transformed'
		d_dine_in_ban d_school_closure d_non_essential_closure d_shelter_in_place
		i.stateid##i.ndays if in_sample & !weekend, noconstant;
	#delimit cr
	
	di _n
	di "RSS = " as result e(rss)
	di "exponent = " as result `exponent' _n
	return scalar rss = e(rss)

end
