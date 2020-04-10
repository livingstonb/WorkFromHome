
clear
`#PREREQ' use "build/output/essential_industries1.dta"

rename code4d naics4d
`#PREREQ' local oesdata "../OES/build/output/oes4d_cleaned.dta"
merge m:1 naics4d using "../OES"
