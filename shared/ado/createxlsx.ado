program createxlsx
	#delimit ;
	syntax [anything] using/
		[, DESCRIPTIONS(string asis)]
		[, SHEETNAMES(string asis)]
		[, TITLE(string asis)];
	#delimit cr
	
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
	
	local i = 1
	local descr: word 1 of `"`descriptions'"'
	while ("`descr'" != "") {
		local ccell = `ccell' + 1
		putexcel A`ccell' = ("`i'") B`ccell' = ("`descr'")
		
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
