clear

// PARSE COMMANDS
syntax [anything(name=commands)]

if "`commands'" == "" {
	local merge3d 1
	local merge5d 1
	local mergecps 0
}
else {
	local merge3d = strpos("`commands'", "3") > 0
	local merge5d = strpos("`commands'", "5") > 0
	local mergecps = strpos("`commands'", "cps") > 0
}

// MERGE 3-DIGIT DATASETS
if `merge3d' {
	capture mkdir "build/temp"
	capture mkdir "build/output"

	* Perform main merges
	do "build/code/merge_3d.do"

	* Reshape wide
	do "build/code/reshape_wide_3d.do"
}

// MERGE 5-DIGIT DATASETS
if `merge5d' {
	clear
	capture mkdir "build/temp"
	capture mkdir "build/output"

	* Perform main merges
	local lvls person fam hh
	foreach lvl of local lvls {
		do "build/code/merge_5d.do" `lvl'
	}

	* Combine levels
	clear
	foreach lvl of local lvls {
		append using "build/temp/merged5d_`lvl'.dta"
	}
	save "build/output/merged5d.dta", replace
}

// MERGE CPS DATA
if `mergecps' {
	do "build/code/merge_cps.do"
	do "build/code/aggregate_cps_statistics.do"
}
