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

// STATS
if `stats' {
	capture mkdir "stats/output"
	
	* Compute employment by occupation for each year
	do "stats/code/employment_by_occupation.do"
	
	* Compute mean wage and employment estimates for 2017 by occupation
	do "stats/code/compute_2017stats.do"
}
