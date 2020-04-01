use save "$SIPPtemp/sipp_temp.dta", clear

// ASSET VARIABLES, PERSON-LEVEL

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
rename tlife_fval val_life_face
replace val_life_face = 0 if (eown_life == 2)
label variable val_life_face "Value of life insurance, face value"
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

// INCOME
rename tpearn grossearn
label variable grossearn "Total gross earnings"

rename tptotinc grossinc
label variable grossinc "Total gross income"

rename thtotinc hhgrossinc
label variable hhgrossinc "HH gross income"

// OCCUPATION
gen nmonthsmax = 0
gen employed_thismonth = 0
gen jmainocc = .
forvalues j = 7(-1)1 {
	local varname tjb`j'_occ
	destring `varname', replace
	bysort personid: egen byte tmp_nmonths = count(`varname')
	
	* Update greatest number of months worked in same occupation
	gen update_mainocc = (tmp_nmonths >= nmonthsmax) & (tmp_nmonths > 0)
	replace nmonthsmax = tmp_nmonths if (update_mainocc == 1)
	replace jmainocc = `j' if (update_mainocc == 1)
	replace employed_thismonth = 1 if (`varname' != 9920) & !missing(`varname')
	drop tmp_nmonths update_mainocc
}
bysort personid: egen monthsemployed = total(employed_thismonth)
label variable monthsemployed "Number of months in which an occupation was reported"

rename jmainocc tmp_jmainocc
bysort personid: egen jmainocc = min(tmp_jmainocc)
label variable jmainocc "Job number of main occupation"
drop tmp_jmainocc

drop employed_thismonth
drop nmonthsmax

gen occcensus = .
forvalues j = 1/7 {
	bysort personid: egen tmp_occmain = min(tjb`j'_occ)
	replace occcensus = tmp_occmain if (jmainocc == `j')
	drop tmp_occmain
}
#delimit ;
merge m:1 occcensus using "$WFHshared/occsipp/output/occindexsipp.dta",
	keepusing(occ3d2010) keep(match master) nogen;
#delimit cr
drop tjb*_occ enjflag ejb*_scrnr

// EMPLOYMENT STATUS
rename rmesr empstatus
gen emptmp = 1 if inrange(empstatus, 1, 5)
replace emptmp = 2 if inrange(empstatus, 6, 7)
replace emptmp = 3 if (empstatus == 8)

bysort personid: egen employment = min(emptmp)
drop emptmp empstatus
label define emplbl 1 "Employed at least one week of the year"
label define emplbl 2 "Unemployed, spent at least one week on layoff or looking for work", add
label define emplbl 3 "Not employed, was not on layoff or looking for work at any time", add
label variable employment "Employment status"
label values employment emplbl

replace occ3d2010 = -1 if missing(occ3d2010) & (employment == 2)
replace occ3d2010 = -2 if missing(occ3d2010) & (employment == 3)
#delimit ;
label define occ3d2010lbl -1
	"Unemployed all year, spent time on layoff or looking for work", add;
label define occ3d2010lbl -2
	"Not employed all year, spent no time on layoff or looking for work", add;
#delimit cr

// WORK FROM HOME
egen workfromhome = anymatch(ejb*_wshmwrk), values(1)
label variable workfromhome "Any days the respondent only worked from home"
label values workfromhome bin_lbl
drop ejb*_wshmwrk

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

compress
save "$SIPPout/sipp_cleaned.dta", replace
