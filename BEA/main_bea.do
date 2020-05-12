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
	
	* Clean price indexes
	do "build/code/clean_price_index.do"
	
	* Clean value added
	do "build/code/clean_value_added.do"
	
	* Create time series with Tornquist index
	do "build/code/compute_tornquist_index.do"
}
