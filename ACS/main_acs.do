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
	capture mkdir "build/temp"
	capture mkdir "build/output"

	* Read
	do "build/code/read_acs.do"

	* Clean
	do "build/code/clean_acs.do"
}

if `stats' {
	* Compute statistics for ACS
	do "stats/code/stats_acs.do"
	
	* Compute ACS statistics for SHED
	do "stats/code/stats_for_shed.do"
}
