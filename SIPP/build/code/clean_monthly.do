/* --- ADDITIONAL MAKEFILE INSTRUCTIONS ---
#PREREQ "../ado/rowdistinct.ado"
*/

/* Dataset: SIPP */
/* This script reads the .dta file after it has been split into chunks,
cleaned somewhat, and recombined. Various variables are recoded and 
new variables are generated. */

`#PREREQ' use "build/temp/sipp_monthly1.dta", clear
adopath + "../ado"

egen personid = group(ssuid pnum)

* See Wave 4 User Notes
replace wpfinwgt = 0 if missing(wpfinwgt)

* Destring occupation and industry
forvalues j = 1/7 {
	destring tjb`j'_occ, replace
	destring tjb`j'_ind, replace
}

// ASSET VARIABLES, PERSON-LEVEL
#delimit ;
local assetvars
	govs ichk sav mm cd mcbd st chk mf rp re;
#delimit cr

local asset_ownvars
local asset_valvars
foreach var of local assetvars {
	local asset_ownvars `asset_ownvars' ejsown`var' ejoown`var' eoown`var'
	local asset_valvars `asset_valvars' tjs`var'val tjo`var'val to`var'val
}

* IRA/KEOGH accounts
rename tirakeoval val_ira_keoh
replace val_ira_keoh = 0 if (eown_irakeo == 2)
label variable val_ira_keoh "Value of IRA and KEOGH accts"
drop eown_irakeo

* 401k and similar accounts
rename tthr401val val_401k
replace val_401k = 0 if (eown_thr401 == 2)
label variable val_401k "Value of 401k and other ret accts"
drop eown_thr401

* Education savings account, also exists at HH level
rename tval_esav val_esa
replace val_esa = 0 if missing(val_esa)
label variable val_esa "Ed sav acct, also avail at HH level"

* Annuities
rename tannval val_ann
replace val_ann = 0 if (eown_anneq == 2)
label variable val_ann "Value of annuities"
drop eown_anneq

* Trusts
rename ttrval val_trusts
replace val_trusts = 0 if (eown_treq == 2)
label variable val_trusts "Value of trusts"
drop eown_treq

* Businesses owned
egen val_bus = rowtotal(tbsj*val tbsi*val)
replace val_bus = 0 if missing(val_bus)
label variable val_bus "Value of personally owned businesses"
drop tbsj*val tbsi*val

* Life insurance
rename tlife_cval val_life
replace val_life = 0 if missing(val_life)
label variable val_life "Value of life insurance, cash value"
drop eown_life

* Other financial investments
rename toinvval val_otherinv
replace val_otherinv = 0 if (eown_oinv == 2)
label variable val_otherinv "Value of other fin investments"
drop eown_oinv

* Assets coded separately for joint ownership
foreach var of local assetvars {
	egen val_`var' = rowtotal(tjs`var'val tjo`var'val to`var'val)
	gen nm_`var'val = (ejsown`var' == 2) | (ejoown`var' == 2) | (eoown`var' == 2)
	replace val_`var' = 0 if missing(val_`var') & nm_`var'val
	drop *`var'val *own`var'
}

label variable val_govs "Value of government securities"
label variable val_ichk "Value of interest-bearing checking accts"
label variable val_sav "Value of savings accts"
label variable val_mm "Value of money market accts"
label variable val_cd "Value of CDs"
label variable val_mcbd "Value of muni or corporate bonds"
label variable val_st "Value of stocks"
label variable val_chk "Value of regular checking accts"
label variable val_mf "Value of mutual funds"
label variable val_rp "Value of rental properties"
local variable val_re "Value of other real estate"

// ASSET VARIABLES, HOUSEHOLD-LEVEL
* Educational saving account
rename thval_esav hhval_esa
replace hhval_esa = 0 if missing(hhval_esa) & (eown_esav == 2)
label variable hhval_esa "Value of educ sav acct"
drop eown_esav

* Primary residence
egen hhval_primaryres = rowtotal(tprval tmhval)
replace hhval_primaryres = 0 if missing(hhval_primaryres)
label variable hhval_primaryres "Value of primary residence"
drop tprval tmhval

* Vehicles
egen hhval_vehicles = rowtotal(tveh*val)
replace hhval_vehicles = 0 if missing(hhval_vehicles)
label variable hhval_vehicles "Value of vehicles"
drop tveh*val

* Recreational vehicles
egen hhval_recveh = rowtotal(tmcycval tboatval trvval torecval)
replace hhval_recveh = 0 if missing(hhval_recveh)
label variable hhval_recveh "Value of recreational vehicles"
drop tmcycval tboatval trvval torecval

// LIABILITIES
* Credit card debt
rename tdebt_cc liab_ccdebt
replace liab_ccdebt = 0 if missing(liab_ccdebt)
label variable liab_ccdebt "Value of credit card debt"

* Primary residence debt
egen hhliab_primaryres = rowtotal(tprloanamt tmhloanamt)
replace hhliab_primaryres = 0 if missing(hhliab_primaryres)
label variable hhliab_primaryres "Value of debt on primary residence"
drop tprloanamt tmhloanamt

// PERSON-LEVEL VARIABLES FOR HH-LEVEL ASSETS/LIABILITIES
rename teq_home val_homeequity
label variable val_homeequity "Value of home equity"

// INCOME
rename tpearn grossearn
label variable grossearn "Total gross earnings"

rename tptotinc grossinc
label variable grossinc "Total gross income"

rename thtotinc hhgrossinc
label variable hhgrossinc "HH gross income"

// FIND MOST-WORKED OCCUPATION FOR EACH INDIVIDUAL
* By wave
levelsof swave, local(waves)

tempfile occwave
foreach wave of local waves {
	preserve

	keep personid swave monthcode tjb*_occ
	keep if swave == `wave'

	reshape wide tjb*_occ, i(personid) j(monthcode)
	rowdistinct tjb*_occ*, gen(distinct_occ) id(personid)
	local ndistinct = `r(ndistinct)'
	drop tjb*_occ*

	
	save `occwave', replace
	restore
	
	merge m:1 personid swave using `occwave', nogen update keep(1 3 4)
}

forvalues j = 1/`ndistinct' {
	forvalues i = 1/7 {
		gen occtmp`i' = (tjb`i'_occ == distinct_occ`j') & !missing(distinct_occ`j')
	}

	egen month_in_`j' = rowmax(occtmp*)
	bysort personid swave: egen nmonths_occ`j' = total(month_in_`j')
	
	drop occtmp* month_in_`j'
}
egen months_primaryocc = rowmax(nmonths_occ*)
replace months_primaryocc = . if months_primaryocc == 0

gen occcensus = .
gen occind = .
forvalues j = 1/`ndistinct' {
	replace occind = `j' if (nmonths_occ`j' == months_primaryocc) & missing(occcensus)
	replace occcensus = distinct_occ`j' if (nmonths_occ`j' == months_primaryocc) & missing(occcensus)
}
drop distinct_occ* nmonths_occ*

// FIND MOST-WORKED INDUSTRY FOR EACH INDIVIDUAL
* By wave
levelsof swave, local(waves)

tempfile indwave
foreach wave of local waves {
	preserve

	keep personid monthcode swave tjb*_ind
	keep if swave == `wave'

	reshape wide tjb*_ind, i(personid) j(monthcode)
	rowdistinct tjb*_ind*, gen(distinct_ind) id(personid)
	local ndistinct = `r(ndistinct)'
	drop tjb*_ind*

	save `indwave', replace

	restore
	merge m:1 personid swave using `indwave', nogen update keep(1 3 4)
}

forvalues j = 1/`ndistinct' {
	forvalues i = 1/7 {
		gen indtmp`i' = (tjb`i'_ind == distinct_ind`j') & !missing(distinct_ind`j')
	}

	egen month_in_`j' = rowmax(indtmp*)
	bysort personid swave: egen nmonths_ind`j' = total(month_in_`j')
	
	drop indtmp* month_in_`j'
}
egen mostmonths = rowmax(nmonths_ind*)
replace mostmonths = . if mostmonths == 0

gen indcensus = .
forvalues j = 1/`ndistinct' {
	replace indcensus = distinct_ind`j' if (nmonths_ind`j' == mostmonths) & missing(indcensus)
}
drop tjb*_ind distinct_ind* mostmonths nmonths_ind*

// RECODE INDUSTRY AND OCCUPATION

* Merge with 3-digit occupation
rename occcensus census2010
`#PREREQ' local occsipp "../occupations/build/output/census2010_to_soc2010.dta"
#delimit ;
merge m:1 census2010 using "`occsipp'",
	keepusing(soc3d2010) keep(match master) nogen;
#delimit cr
replace soc3d2010 = 472 if census2010 == 6765
rename census2010 occcensus
rename soc3d2010 occ3d2010
drop ejb*_scrnr

* Map industry to C/S sector
rename indcensus ind2012
`#PREREQ' local cwlk "../industries/build/output/census2012_to_sector.dta"
#delimit ;
merge m:1 ind2012 using "`cwlk'",
	nogen keep(match master) keepusing(sector);
#delimit cr

// EMPLOYMENT STATUS
rename rmesr empstatus
gen emptmp = 1 if inrange(empstatus, 1, 5)
replace emptmp = 2 if inrange(empstatus, 6, 7)
replace emptmp = 3 if (empstatus == 8)

bysort personid swave: egen employment = min(emptmp)
drop emptmp empstatus
label define emplbl 1 "Employed at least one week of the year"
label define emplbl 2 "Unemployed, spent at least one week on layoff or looking for work", add
label define emplbl 3 "Not employed, was not on layoff or looking for work at any time", add
label variable employment "Employment status"
label values employment emplbl

replace occ3d2010 = -1 if missing(occ3d2010) & (employment == 2)
replace occ3d2010 = -2 if missing(occ3d2010) & (employment == 3)
#delimit ;
label define soc3d2010_lbl -1
	"Unemployed all year, spent time on layoff or looking for work", add;
label define soc3d2010_lbl -2
	"Not employed all year, spent no time on layoff or looking for work", add;
#delimit cr

// WORK FROM HOME
* Worked from home in any occupation
egen yeswfh = anymatch(ejb*_wshmwrk), values(1)
egen nm_wfh = rownonmiss(ejb*_wshmwrk)
gen workfromhome = (yeswfh == 1)
replace workfromhome = . if (nm_wfh == 0)
label variable workfromhome "Any days the respondent only worked from home"
label values workfromhome bin_lbl
drop nm_wfh yeswfh

* Worked from home in main occupation
forvalues j = 1/7 {
	replace ejb`j'_wshmwrk = . if (tjb`j'_occ != occcensus)
	recode ejb`j'_wshmwrk (2 = 0)
}
egen wfh_mainocc = anymatch(ejb*_wshmwrk), values(1)
label variable wfh_mainocc "There were days R worked only from home in main occ"
label values wfh_mainocc bin_lbl
drop ejb*_wshmwrk tjb*_occ

// PROVIDED RECODES
rename thnetworth recode_hhnetworth
rename thval_bank recode_hhbank
rename thval_ret recode_hhretir
rename theq_home recode_hhhomeequity
rename thval_ast recode_hhassets
rename thdebt_ast recode_hhdebt
rename tdebt_ast recode_pdebt
rename tval_ast recode_passets

foreach var of varlist recode_* {
	replace `var' = 0 if missing(`var')
	
	local nameedit = substr("`var'", 8, .)
	rename `var' `nameedit'
}

// OTHER VARIABLES
rename efood3 nofoodmoney
recode nofoodmoney (2 = 0)
label values nofoodmoney bin_lbl

rename efood4 freq_nofoodmoney
replace freq_nofoodmoney = 4 if (nofoodmoney == 0)
label define freq_nofoodmoney_lbl 1 "Almost every month"
label define freq_nofoodmoney_lbl 2 "Some months", add
label define freq_nofoodmoney_lbl 3 "Only 1 or 2 months", add
label define freq_nofoodmoney_lbl 4 "Never", add
label values freq_nofoodmoney freq_nofoodmoney_lbl

gen foodinsecure = inrange(freq_nofoodmoney, 1, 3) if !missing(freq_nofoodmoney)
label values foodinsecure bin_lbl
label variable foodinsecure "Cut or skipped meals in at least one month b/c not enough money"

replace foodinsecure = 1 if (efood5 == 1) | (efood6 == 1)
drop efood*

rename eawbgas couldntpayutil
recode couldntpayutil (2 = 0)
label values couldntpayutil bin_lbl

gen qualitative_h2m = foodinsecure
replace qualitative_h2m = 1 if (couldntpayutil == 1)
label variable qualitative_h2m "HH was food-insecure and/or unable to pay utility bills"
label values qualitative_h2m bin_lbl

compress
`#TARGET' save "build/temp/sipp_monthly2.dta", replace
