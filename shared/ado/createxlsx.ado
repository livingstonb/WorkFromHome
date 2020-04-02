program sl_createxlsx
	#delimit ;
	syntax [anything(name=args)] using/ ;
	#delimit cr
	
	local descriptions: word 1 of `args'
	local sheets: word 2 of `args'
	local xlxnotes: word 3 of `args'
	
	putexcel set "`using'", replace sheet("Contents")

	local i = 1
	`xlxnotes'.loop_reset
	while( ``xlxnotes'.loop_next' ) {
		local inote = "``xlxnotes'.loop_get'"
		putexcel A`i' = ("``xlxnotes'.loop_get'")
		local ++i
	}

	putexcel A`i' = ("Date: $S_DATE")
	local ++i
	
	putexcel A`i' = ("Time: $S_TIME")
	local ++i
	local ++i

	putexcel A`i' = "SHEET" B`i' = "DESCRIPTION"
	local ++i
	
	putexcel A`i' = ("0") B`i' = "Contents"
	local ++i
	
	`descriptions'.loop_reset
	while ( ``descriptions'.loop_next' ) {
		local isheet = ``descriptions'.i'
		local descr = "``descriptions'.loop_get'"
		putexcel A`i' = ("`isheet'") B`i' = ("`descr'")
		local ++i
	}

	`descriptions'.loop_reset
	`sheets'.loop_reset
	while ( ``descriptions'.loop_next' & ``sheets'.loop_next' ) {
		
		putexcel set "`using'", modify sheet("``sheets'.loop_get'")
		putexcel A1 = ("``descriptions'.loop_get'")
	}
end
