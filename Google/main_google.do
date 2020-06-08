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
	
	do "build/code/clean_county_land_area.do"
	
	do "build/code/clean_jhu.do"
	
	do "build/code/clean_mobility_report.do"
	
	do "build/code/clean_other_inputs.do"
	
	do "build/code/merge_counties.do"
}

if `stats' {
	do "stats/code/estimate.do"
}
