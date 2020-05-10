
`#PREREQ' use "stats/temp/SIPP5d_person.dta", clear
`#PREREQ' append using "stats/temp/SIPP5d_fam.dta"
`#PREREQ' append using "stats/temp/SIPP5d_hh.dta"

`#TARGET' save "stats/output/SIPP5d_final.dta", replace
