// NOTE: FIRST RUN "do macros.do" IN THE MAIN DIRECTORY

/* Dataset: SIPP */
/* This is the main build script for the 2014 SIPP. If the raw dataset
has not been broken into chunks, first use read.do. */

clear mata
forvalues wavenum = 3/4 {
	global wave = `wavenum'

	do "$SIPPbuild/drop_variables.do"
	do "$SIPPbuild/gen_variables_monthly.do"
	do "$SIPPbuild/create_samplingunit.do"
	do "$SIPPbuild/aggregate2annual.do"
}
global wave
