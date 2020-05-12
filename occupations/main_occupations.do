clear

// PARSE COMMANDS
syntax [anything(name=commands)]

if "`commands'" == "" {
	local build = 1
	local stats = 1
}
else {
	local build = strpos("`commands'", "build") > 0
	local stats = strpos("`commands'", "stats") > 0
}


// BUILD
if `build' {
	capture mkdir "build/output"

	* Create value labels and datasets containing all occ values
	do "build/code/census_soc_labels.do" 2010
	
	* Create crosswalks from Census codes to SOC categories
	do "build/code/census_to_soc2010.do" 2010
	do "build/code/census_to_soc2010.do" 2018
	
	* Other crosswalks for OES data
	do "build/code/occ2010_to_soc3d2010.do"
	do "build/code/soc98_to_soc3d2010.do"
	do "build/code/oes99_to_soc3d2010.do"
	do "build/code/soc2000_to_soc3d2010.do"
	
}
