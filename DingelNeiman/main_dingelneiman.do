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

	* Prepare 2017 OES dataset
	do "build/code/prepare_oes.do"
	
	* 3-digit occupations
	do "build/code/onet_teleworkable_3d.do"
	
	* 5-digit occupations
	do "build/code/manual_teleworkable_5d.do"
	
	* By industry
	do "build/code/onet_teleworkable_industry.do"
}
