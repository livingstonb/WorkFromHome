/* --- HEADER ---
Labels NAICS codes according to our classification.
*/

args industry_variable

label define naics_lbl 11 "Agriculture, Forestry, Fishing and Hunting", replace
label define naics_lbl 21 "Mining, Quarrying, and Oil and Gas Extraction", add
label define naics_lbl 22 "Utilities", add
label define naics_lbl 23 "Construction", add
label define naics_lbl 31 "Manufacturing", add
label define naics_lbl 42 "Wholesale Trade", add
label define naics_lbl 44 "Retail Trade", add
label define naics_lbl 48 "Transportation and Warehousing", add
label define naics_lbl 51 "Information", add
label define naics_lbl 52 "Finance and Insurance", add
label define naics_lbl 53 "Real Estate and Rental Leasing", add
label define naics_lbl 54 "Professional, Scientific, and Technical Services", add
label define naics_lbl 55 "Management of Companies and Enterprises", add
label define naics_lbl 56 "Administrative and Support and Waste Management and Remediation Services", add
label define naics_lbl 61 "Educational Services", add
label define naics_lbl 62 "Health Card and Social Assistance", add
label define naics_lbl 71 "Arts, Entertainment, and Recreation", add
label define naics_lbl 72 "Accommodation", add
label define naics_lbl 81 "Other Services (except Public Administration)", add
label define naics_lbl 92 "Public Administration", add

if ("`industry_variable'" != "") {
	recode `industry_variable' (32/33 = 31) (45 = 44) (49 = 48) (99 = 92)
}
else {
	local vals
	local nvals = 0
	forvalues i = 1/99 {
		local lab: label naics_lbl `i'
		if ("`lab'" != "`i'") {
			local vals `vals' `i'
			local ++nvals
		}
	}
	expand `nvals'
	sort soc2010
	egen `industry_variable' = fill(`vals' `vals')
}
label values `industry_variable' naics_lbl
