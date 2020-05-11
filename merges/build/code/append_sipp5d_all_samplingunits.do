
local lvls person fam hh

foreach lvl of local lvls {
	do "build/code/merge_wfh_5d.do" `lvl'
}
clear

foreach lvl of local lvls {
	append using "build/output/merged5d_`lvl'.dta"
}
// `#PREREQ' use "build/output/merged5d_person.dta", clear
// `#PREREQ' append using "build/output/merged5d_fam.dta"
// `#PREREQ' append using "build/output/merged5d_hh.dta"

`#TARGET' save "build/output/merged5d_final.dta", replace
