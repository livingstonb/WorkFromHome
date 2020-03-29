program sl_createxlsx
	#delimit ;
	syntax [anything(name=args)] using/
		[, TITLE(string asis)];
	#delimit cr
	
	local descriptions: word 1 of `args'
	local sheets: word 2 of `args'
	
	putexcel set "`using'", replace sheet("Contents")
	
	local i = 1
	local tword: word 1 of `"`title'"'
	while ("`tword'" != "") {
		putexcel A`i' = ("`tword'")
		
		local ++i
		local tword: word `i' of `"`title'"'
	}
	
	local ccell = `i' + 1
	putexcel A`ccell' = "SHEET" B`ccell' = "DESCRIPTION"
	
	`descriptions'.loop_reset
	while ( ``descriptions'.loop_next' ) {
		local ++ccell
		local i = ``descriptions'.i'
		local descr = "``descriptions'.loop_get'"
		putexcel A`ccell' = ("`i'") B`ccell' = ("`descr'")
	}

	`descriptions'.loop_reset
	`sheets'.loop_reset
	while ( ``descriptions'.loop_next' & ``sheets'.loop_next' ) {
		
		putexcel set "`using'", modify sheet("``sheets'.loop_get'")
		putexcel A1 = ("``descriptions'.loop_get'")
	}
end
