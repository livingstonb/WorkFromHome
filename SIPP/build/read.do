// NOTE: FIRST RUN "do macros.do" IN THE MAIN DIRECTORY

/* Dataset: SIPP */
/* This script reads the raw data from the .dta file, drops some variables,
compresses, and resaves as .dta files. Done in chunks of 50,000 observations. */

forvalues chunk = 1/10 {
	local start = (`chunk' - 1) * 50000 + 1
	local stop = min(492776, `start' + 50000 - 1)
	di "`start' to `stop'"
	use in `start'/`stop' using "input/pu2014w4.dta", clear
	drop a*
	compress
	
	save "input/wave4pt`chunk'.dta", replace
}
clear
