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
	
	* Crosswalk from 2012 Census to sector C/S
	do "build/code/census2012_to_sector.do"
	
	* Make list of all industries with a dummy for essential industry
	do "build/code/produce_essential_industry_list.do"
}

if `stats' {
	capture mkdir "stats/output"

	* Compute share of each occupation deemed essential
	do "build/stats/code/share_essential_by_occupation.do"
}
