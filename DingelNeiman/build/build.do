clear

import delimited "$DNbuild/input/occupations_workathome.csv"
gen soc2010 = substr(onetsoccode, 1, 7)
gen soc3d = substr(soc2010, 1, 4)

preserve

tempfile occtmp
use "$WFHshared/occ2010/output/occindex2010new.dta", clear
gen soc3d = substr(soc2010, 1, 4)
duplicates drop soc3d, force

save `occtmp'

restore

merge m:1 soc3d using `occtmp', keepusing(occ3d2010) nogen keep(match)
drop soc2010 soc3d

export excel "$DNout/DingelNeiman_merged.xlsx", firstrow(varlabels) replace
