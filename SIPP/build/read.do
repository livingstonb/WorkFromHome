clear

cd "$SIPPbuild"
set maxvar 10000

// forvalues chunk = 1/10 {
// 	local start = (`chunk' - 1) * 50000 + 1
// 	local stop = min(492776, `start' + 50000 - 1)
// 	di "`start' to `stop'"
// 	use in `start'/`stop' using "input/pu2014w4.dta", clear
// 	drop a*
// 	compress
//	
// 	save "input/wave4pt`chunk'.dta", replace
// }

* Asset variables separately coded for joint and single ownership
#delimit ;
local assetvars
	govs ichk sav mm cd mcbd st chk mf rp
	re;
#delimit cr

local asset_ownvars
local asset_valvars
foreach var of local assetvars {
	local asset_ownvars `asset_ownvars' ejsown`var' ejoown`var' eoown`var'
	local asset_valvars `asset_valvars' tjs`var'val tjo`var'val to`var'val
}


#delimit ;
local keepvars
	tage eeduc eorigin ems epnspouse erace esex efindjob
	rged pnum spanel ssuid
	eown_anntr ejb1_wshm* ejb1_clwrk ghlfsam
	rfamnum rfamkind monthcode
	
	
/* Employment and income variables */
	tjb1_occ tjb2_occ tpearn
	tptotinc thtotinc

/* Asset variables, person-level */
	tirakeoval eown_irakeo
	tthr401val eown_thr401
	tval_esav
	`asset_ownvars'
	`asset_valvars'
	tannval eown_anneq
	ttrval eown_treq
	tbsj*val tbsi*val
	tlife_fval eown_life
	toinvval eown_oinv
	tdebt_ast tval_ast
	
/* Asset variables, household-level */
	thval_esav eown_esav
	tprval tmhval
	tveh*val
	tmcycval tboatval trvval torecval
	thnetworth thval_bank thval_ret theq_home
	thval_ast thdebt_ast

/* Liabilities */
	tdebt_cc
	tprloanamt tmhloanamt
	
/* Household-related variables */
	eresidenceid;
#delimit cr

use `keepvars' using "input/wave4pt1.dta", clear
forvalues chunk = 2/10 {
	append using "input/wave4pt`chunk'.dta", keep(`keepvars')
}
keep if (tage >= 15)


* NOTE: families uniquely identified by ssuid & rfamnum
* HHs uniquely identified by ssuid & eresidenceid, in a given month
* HH/family composition can change month to month-to-month

* Rename important variables
// rename rfamnum familyid

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

// KEEP ONLY THE LAST MONTH
keep if (monthcode == 12)
drop monthcode

