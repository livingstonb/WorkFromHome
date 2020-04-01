// DIRECTORIES
cd "$WFHshared/occ2010/occ"
capture mkdir "temp"

// CREATE UNIQUE SOC2010 3D MAPPING TO LABELS
use "$WFHshared/occ2010/temp/soc2010.dta", clear

gen threedigits2010 = substr(soc3d2010, 1, 4)

duplicates drop occ3d2010 soc3d2010, force
save "$WFHshared/occ2010/occ/temp/minor_groups_2010.dta", replace

// CREATE UNIQUE SOC2018 3D MAPPING TO LABELS
use "$WFHshared/occ2018/temp/soc2018.dta", clear

duplicates drop occ3d2018 soc3d2018, force
save "$WFHshared/occ2010/occ/temp/minor_groups_2018.dta", replace


// USE 2010-2018 CROSSWALK
clear
import delimited "$WFHshared/occ2010/occ/input/crosswalk_2010_2018.csv", bindquotes(strict)
drop if missing(census2018) & missing(census2010)

* Replace Xs with 0s
replace soc2010 = subinstr(soc2010, "X", "0", .)
replace soc2018 = subinstr(soc2018, "X", "0", .)

* Create 2010 SOC 3-digit variable
gen soc3d2010 = substr(soc2010, 1, 4)
gen soctmp = "000"

replace soc3d2010 = soc3d2010 + soctmp if !missing(soc3d2010)
drop soctmp

replace soc3d2010 = "51-5100" if (soc3d2010 == "51-5000")
replace soc3d2010 = "15-1100" if (soc3d2010 == "15-1000")

* Create 2018 SOC 3-digit variable
gen soc3d2018 = substr(soc2018, 1, 4)
gen soctmp = "000"

replace soc3d2018 = soc3d2018 + soctmp if !missing(soc3d2018)
drop soctmp

replace soc3d2018 = "51-5100" if (soc3d2018 == "51-5000")
replace soc3d2018 = "15-1200" if (soc3d2018 == "15-1000")
replace soc3d2018 = "31-1100" if (soc3d2018 == "31-1000")

* Merge 2010 with labels
#delimit ;
merge m:1 soc3d2010 using "$WFHshared/occ2010/occ/temp/minor_groups_2010.dta",
	keepusing(occ3d2010) keep(match master) nogen;
#delimit cr
rename occ3d2010 minor2010

* Merge 2018 with labels
#delimit ;
merge m:1 soc3d2018 using "$WFHshared/occ2010/occ/temp/minor_groups_2018.dta",
	keepusing(occ3d2018) keep(match master) nogen;
#delimit cr
rename occ3d2018 minor2018

// * Note changes to SOC code
// gen newsoc = missing(soc2010) & !missing(soc2018)
// label define newsoclbl 1 "New SOC occupation" 0 ""
// label values newsoc newsoclbl
//
// gen socchange = (soc2010 != soc2018)

// GENERATE UNIFIED SOC MINOR GROUP
* Create variables holding strings for SOC minor groups
decode minor2010, gen(labs2010)
decode minor2018, gen(labs2018)

* Use all groups in common
gen minor_harmonized = labs2010 if (labs2010 == labs2018)

* Use 2010 groups if 2018 is absent
replace minor_harmonized = labs2010 if missing(census2018)

* Use 2010 groups if minor group numbering is the same
replace minor_harmonized = labs2010 if missing(minor_harmonized) & (soc3d2010 == soc3d2018)

* Use 2010 group for 2018 census codes if 2010 code is provided in crosswalk
replace minor_harmonized if missing(minor_harmonized) & (soc3d2010 )
