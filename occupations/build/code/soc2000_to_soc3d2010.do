/* --- HEADER ---
Creates a crosswalk between SOC 2000 and SOC 2010 three-digit occupation codes.
*/

clear
`#PREREQ' local soc_cwalk "build/input/soc_2000_to_2010_crosswalk.csv"
import delimited "`soc_cwalk'", varname(1)
drop if _n == 1

replace soc2000 = strtrim(soc2000)
replace soc2010 = strtrim(soc2010)

* If soc2000 maps to multiple soc2010 codes, try to find the closest
* match by code number
gen socnum2000 = subinstr(soc2000, "-", "", .)
gen socnum2010 = subinstr(soc2010, "-", "", .)
destring socnum2000, replace
destring socnum2010, replace

gen socdiff = abs(socnum2010 - socnum2000)
bysort socnum2000: egen mindiff = min(socdiff)
bysort socnum2000: gen idiff = (socdiff == mindiff)
keep if idiff
drop mindiff idiff socdiff


gen change = (soc2000 != soc2010)
foreach yr of numlist 2000 2010 {
	gen soc3d`yr' = substr(soc`yr', 1, 4)
	replace soc3d`yr' = subinstr(soc3d`yr', "-", "", .)
	destring soc3d`yr', replace
}
keep soc*

label data "Crosswalk from SOC2000-3 to SOC2010-3"
`#TARGET' save "build/output/soc2000_to_soc3d2010.dta", replace
