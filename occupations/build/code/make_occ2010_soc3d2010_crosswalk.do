/* --- HEADER ---
Creates a crosswalk from OCC2010 to soc3d2010 for the ACS.
*/

clear
`#PREREQ' import excel "build/input/acs_occ2010_occ_crosswalk", firstrow
keep occ2010 census2010

replace occ2010 = strtrim(occ2010)
replace census2010 = strtrim(census2010)

destring occ2010, force replace
destring census2010, force replace
drop if missing(census2010)

* Replace some older codes with newer codes
replace census2010 = 1815 if (census2010 == 1810)
replace census2010 = 3955 if (census2010 == 3950)
replace census2010 = 9050 if (census2010 == 4550)
drop if census2010 >= 9800

`#PREREQ' merge m:1 census2010 using "build/output/occindex2010.dta"

* Some occ2010 codes correspond with multiple census2010 codes
* and some census2010 codes are not used for ACS < 2012
* For these occ2010 codes, map them to soc3d2010 if constant within
* group
bysort occ2010: egen soc3dmin = min(soc3d2010)
bysort occ2010: egen soc3dmax = max(soc3d2010)
replace soc3d2010 = soc3dmin if (soc3dmin == soc3dmax) & missing(soc3d2010)

* Drop duplicates
duplicates drop occ2010 soc3d2010, force
drop if missing(occ2010)

* Drop likely bad matches
drop if (occ2010 == 3950) & (soc3d2010 == 339)
drop if (occ2010 == 4000) & (soc3d2010 == 351)
drop if (occ2010 == 9050) & (soc3d2010 == 536)

`#TARGET' save "build/output/cwalk_acs_occ2010_soc3d2010.dta", replace
