program mat2excel, rclass
	#delimit ;
	syntax namelist(name=name) using/
		[, COLNAMES(namelist)]
		[, TITLE(string)]
		[, REPLACE]
		[, SHEET(string)];
	#delimit cr

	matrix stats = `name'

	if "`colnames'" != "" {
		matrix colnames stats = `colnames'
	}
	matrix list stats

	* Output to excel
	if "`replace'" == "" {
		local xlx_options "modify"
	}
	else {
		local xlx_options "replace"
	}

	if "`sheet'" != "" {
		local xlx_options `xlx_options' sheet("`sheet'")
	}

	putexcel set "`using'", `xlx_options'


	if "`title'" != "" {
		putexcel A1 = "`title'"
	}
	putexcel A3 = matrix(stats), names

	return matrix stats = stats
end