program createxlsx
	syntax [anything] using/ [, DESCRIPTIONS(string asis)] [, SHEETNAMES(string asis)]
	
	putexcel set "`using'", replace sheet("Contents")
	putexcel A1 = "SHEET" B1 = "DESCRIPTION"
	
	local i = 1
	local descr: word 1 of `"`descriptions'"'
	while ("`descr'" != "") {
		putexcel A`i' = ("`i'") B`i' = ("`descr'")
		
		local ++i
		local descr: word `i' of `"`descriptions'"'
	}
	
	local i = 1
	local sname: word 1 of `"`sheetnames'"'
	local descr: word 1 of `"`descriptions'"'
	while ("`descr'" != "") {
		putexcel set "`using'", modify sheet("`sname'")
		putexcel A1 = ("`descr'")
		
		local ++i
		local sname: word `i' of `"`sheetnames'"'
		local descr: word `i' of `"`descriptions'"'
	}
end
