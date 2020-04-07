clear

import delimited "$DNbuild/input/occupations_workathome.csv"
gen soc2010 = substr(onetsoccode, 1, 7)
gen soc3d2010 = substr(soc2010, 1, 4)
replace soc3d2010 = subinstr(soc3d2010, "-", "", .)
destring soc3d2010, replace

// Label 3-digit categories
do "$WFHshared/occupations/output/occ3labels2010.do"
label values soc3d2010 soc3d2010_lbl

* Save
save "$DNbuildtemp/DN_temp.dta", replace

// Output to excel
drop soc2010 onetsoccode
export excel "$DNout/DingelNeiman_merged.xlsx", firstrow(varlabels) replace

