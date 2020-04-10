/* Dataset: SIPP */
/* This script reads the raw data from the .dta file, drops some variables,
compresses, and resaves as .dta files. Done in chunks of 50,000 observations. */

/* Must first set the wave. */
args wave

clear
set maxvar 10000
log using "build/read_sipp.log", text replace

if `wave' == 1 {
	local nchunks 18
	local nobs 870352
}
else if `wave' == 2 {
	local nchunks 14
	local nobs 676105
}
else if `wave' == 3 {
	local nchunks 12
	local nobs 556943
}
else if `wave' == 4 {
	local nchunks 10
	local nobs 492776
}

forvalues chunk = 1/`nchunks' {
	local start = (`chunk' - 1) * 50000 + 1
	
	local stop = min(`nobs', `start' + 50000 - 1)
	di "`start' to `stop'"
	use in `start'/`stop' using "build/input/pu2014w${wave}.dta", clear
	drop a*
	compress
	
	save "build/input/wave${wave}pt`chunk'.dta", replace
}
clear

clear
forvalues chunk = 1/`nchunks' {
	append using "build/input/wave`wave'pt`chunk'.dta"
}
foreach var of varlist tjb*_occ tjb*_ind {
	destring `var', replace
}
save "build/input/wave`wave'_complete.dta"

global wave
log close