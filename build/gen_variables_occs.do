clear

label define bin_lbl 0 "No" 1 "Yes", replace

* Read data after coding missing values
use "$build/temp/occ_ind_temp.dta", clear

* Nominal wage income
gen nincwage = incwage
label variable nincwage "Wage and salary income, nominal"

* Adjust income to 2018 prices
quietly sum cpi99 if (year == 2018)
local cpi1999_2018 = `r(max)'
gen cpi2018 = cpi99 / `cpi1999_2018'

replace incwage = cpi2018 * incwage

// SAMPLE RESTRICTIONS
drop if (incwage < 1000) | missing(incwage)
// drop if (wkswork2 == 0) | missing(wkswork2)
// drop if (uhrswork == 0) | missing(uhrswork)

// COMPUTE OCCUPATION SHARES BY INDUSTRY
drop if missing(indcat)
drop if missing(occat)

gen nworkers = 1
collapse (rawsum) nresp=nworkers (sum) nworkers [iw=perwt], by(indcat occcat)
label variable nresp "Num respondents in occ-industry pair"
label variable nworkers "Num workers in occ-industry pair"

bysort indcat: egen indworkers = total(nworkers)
label variable indworkers "Num workers in industry"

gen ioshare = nworkers / indworkers
replace ioshare = . if (indworkers == 0)
label variable ioshare "Share of industry workers of this occ"
