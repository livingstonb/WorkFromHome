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
	
	do "build/code/read_shed.do"
	do "build/code/clean_shed.do"
}

// STATS
if `stats' {
	* Create statistics table
	do "stats/code/summary_stats.do"
}
