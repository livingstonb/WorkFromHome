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

	* Clean Google mobility data
	do "build/code/clean_mobility_report.do"

	* Clean Census data on county land area
	do "build/code/clean_county_land_area.do"
	
	* Clean county-level NPIs
	do "build/code/clean_county_npis.do"
	
	* Clean other datasetsd
	do "build/code/clean_other_inputs.do"
	
	* Merge state-level data
	do "build/code/merge_states.do"
	
	* Merge county-level data
	do "build/code/merge_counties.do"
}

if `stats' {
}
