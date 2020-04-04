// NOTE: FIRST RUN "do macros.do" IN THE MAIN DIRECTORY

/* Dataset: SIPP */
/* This script reads the .dta chunks of the raw data, extracting
needed variables. */

/* Must first set the global macro: wave. */

clear

cd "$SIPPbuild"
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


#delimit ;
local keepvars
	tage eeduc eorigin ems erace esex efindjob
	rged pnum spanel ssuid wpfinwgt tage_ehc
	eown_anntr ejb*_wshmwrk ejb1_clwrk ghlfsam
	rfamnum rfamkind monthcode swave
	
/* Employment and income variables */
	tjb*_occ tpearn
	tjb*_ind
	ejb*_scrnr
	tptotinc thtotinc
	enjflag
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
	rpnpar1_ehc rpnpar2_ehc;
#delimit cr

/* Now combine */
if $wave == 3 {
	local nchunks 12
}
else if $wave == 4 {
	local nchunks 10
}

use `keepvars' using "input/wave${wave}pt1.dta", clear
forvalues chunk = 2/`nchunks' {
	append using "input/wave${wave}pt`chunk'.dta", keep(`keepvars')
}
drop if (tage < 15) | missing(tage)

* NOTE: families uniquely identified by ssuid & eresidenceid & rfamnum
* HHs uniquely identified by ssuid & eresidenceid, in a given month
* HH/family composition can change month to month-to-month

destring ssuid, replace
compress
save "$SIPPtemp/sipp_combined_w${wave}.dta", replace


