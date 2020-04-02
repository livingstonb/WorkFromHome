program create_sampling_unit
	#delimit ;
	syntax varlist
		[, GEN(namelist)]
		[, PANELID(varlist)]
		[, PANELRANGE(numlist)]
		[, REPLACE];
	#delimit cr
	
	if "`replace'" == "replace" {
		capture drop `gen'
	}
	
	local dhead: word 1 of `varlist'
	local dspouse: word 2 of `varlist'
	local igroup: word 3 of `varlist'
	local iind: word 4 of `varlist'
	
	tokenize "`panelrange'"
	local t0 = `1'
	local t1 = `2'
	local nperiods = `2' - `1' + 1
	
	* Create unique group identifier
	tempvar nind headchk
	bysort `iind': gen `nind' = _N
	bysort `iind': egen `headchk' = min(`dhead')
	
	gen `alwayshead' = (`nind' == `nperiods') & (`headchk' == 1)
	gen `gen' = `iind' if (`alwayshead' == 1)
	
	* Pair with spouse
	tempvar groupconst candidate
	bysort `igroup': egen `groupconst' = max(`gen')
	bysort `iind': egen `candidate' = max(`dspouse')
	
	* Check if candidate spouse is available in all periods
	tempvar isavail
	bysort `iind': gen `isavail' = (_N == `nperiods')
	replace `isavail' = . if (`candidate' == 0)
	
	* Check if married to head for all periods
	tempvar marriedall
	bysort `iind': egen `marriedall' = min(`dspouse')
	replace `marriedall' = . if (`candidate' == 0)
	
	* Apply group index to spouse
	tempvar applyspouse
	gen `applyspouse' = (`marriedall' == 1) & (`isavail' == 1)
	replace `gen' = `groupconst' if (`applyspouse' == 1)
end



class samplingunit {
	string groupid = "_sampleunit"
	string memberid = "_memberid"
	string aweight = "_aweight"
	string indid
	string dyngroupid
	string panelid
	string grouphead
	string required = "_required"
	string omitted = "_omitted"
	
	double nperiods
	double panel0
	double panelT
}
program .set_groupid
	args x
	.dyngroupid = "`x'"
end
program .set_individualid
	args x
	.indid = "`x'"
end
program .set_panelid
	syntax varlist [, RANGE(numlist)]
	.panelid = "`varlist'"
	
	tokenize `range'
	.panel0 = `1'
	.panelT = `2'
	.nperiods = `2' - `1' + 1
end
program .set_grouphead
	args x
	.grouphead = "`x'"
end
