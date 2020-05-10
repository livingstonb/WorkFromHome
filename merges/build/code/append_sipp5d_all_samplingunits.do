
`#PREREQ' use "build/output/merged5d_person.dta", clear
`#PREREQ' append using "build/output/merged5d_fam.dta"
`#PREREQ' append using "build/output/merged5d_hh.dta"

`#TARGET' save "build/output/merged5d_final.dta", replace
