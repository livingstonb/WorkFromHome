/* --- HEADER ---
This script cleans the teleworkable measure constructed by
Dingel and Neiman.
*/

clear

`#PREREQ' import delimited "build/input/occupations_workathome.csv"
gen soc2010 = substr(onetsoccode, 1, 7)
gen soc3d2010 = substr(soc2010, 1, 4)
replace soc3d2010 = subinstr(soc3d2010, "-", "", .)
destring soc3d2010, replace

// Label 3-digit categories
`#PREREQ' do "../occupations/build/output/soc3dlabels2010.do"
label values soc3d2010 soc3d2010_lbl

* Save
`#TARGET' save "build/temp/DN_temp.dta", replace

// Output to excel
drop soc2010 onetsoccode
`#TARGET' local dnout "build/output/DingelNeiman_merged.xlsx"
export excel "`dnout'", firstrow(varlabels) replace