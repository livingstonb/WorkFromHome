
clear
import excel "build/input/soc2010_to_soc2018.xlsx", firstrow

gen num2010 = subinstr(soc2010, "-", "", .)
gen num2018 = subinstr(soc2018, "-", "", .)

destring num2010, force replace
destring num2018, force replace
keep if !missing(num2018)

gen soc3d2010 = floor(num2010 / 1000)
bysort soc2018 (soc3d2010): gen unique = (soc3d2010[_N] == soc3d2010[1])
drop if !unique
drop unique

keep soc2018 soc3d2010
drop if soc3d2010 >= 550

label data "Crosswalk from SOC2018 to SOC2010-3"
`#TARGET' save "build/output/soc2018_to_soc3d2010.dta", replace
