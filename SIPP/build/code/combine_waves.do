/* --- HEADER ---
Reads the .dta chunks of the raw data, extracting
needed variables and combining waves.

#PREREQ "build/input/sipp_raw_w1.dta"
#PREREQ "build/input/sipp_raw_w2.dta"
#PREREQ "build/input/sipp_raw_w3.dta"
#PREREQ "build/input/sipp_raw_w4.dta"
*/

clear
set maxvar 10000

label define bin_lbl 0 "No" 1 "Yes"

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

/* Possible variables of interest
eeduc eorigin ems erace esex efindjob
rged eown_anntr rfamkind ejb*_pvwktr9
*/

#delimit ;
local keepvars
	tage pnum spanel ssuid wpfinwgt tage_ehc
	ejb*_wshmwrk ejb1_clwrk 
	rfamnum monthcode swave
	
/* Employment and income variables */
	tjb*_occ tpearn
	tjb*_ind
	ejb*_scrnr
	tptotinc thtotinc
	rmesr

/* Asset variables, person-level */
	tirakeoval eown_irakeo
	tthr401val eown_thr401
	tval_esav
	`asset_ownvars'
	`asset_valvars'
	tannval eown_anneq
	ttrval eown_treq
	tbsj*val tbsi*val
	tlife_cval eown_life
	toinvval eown_oinv
	tdebt_ast tval_ast
	teq_home
	
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
	eresidenceid rfamref
	epnspous_ehc epncohab_ehc
	rpnpar1_ehc rpnpar2_ehc
	ems erelrpe epnspouse
	
/* Other HtM measures */
	efood3 efood4 efood5 efood6 eawbgas
;
#delimit cr

tempfile rawdata
save `rawdata', emptyok

local conds (tage > 15) & !missing(tage)
forvalues i = 1/4 {
	tempfile raw`i'
	use `keepvars' if `conds' using "build/input/sipp_raw_w`i'.dta", clear
	append using `rawdata'
	save `rawdata', replace
}

* NOTE: families uniquely identified by ssuid & eresidenceid & rfamnum
* HHs uniquely identified by ssuid & eresidenceid, in a given month
* HH/family composition can change month to month-to-month

destring ssuid, replace
compress
`#TARGET' save "build/temp/sipp_monthly1.dta", replace
