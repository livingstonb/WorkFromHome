clear
// adopath + "../ado"

import delimited "build/input/bea_value_added_sector.csv", varnames(1)
replace description = strtrim(description)

label define sector_lbl 0 "C" 1 "S"
label values sector sector_lbl

save "build/output/bea_value_added_sector.dta", replace

// * Prepare NAICS codes
// tempfile naicstmp
// import delimited "build/input/naics_codes.csv", varnames(1)
// replace naics = strtrim(naics)
// keep if strlen(naics) == 2 | strlen(naics) == 3
// destring naics, replace
//
// rename description name
// replace name = strtrim(name)
// replace name = lower(name)
//
// bysort name (naics): gen obs = _n
// drop if obs > 1
//
// compress
// save `naicstmp'
//
// * Read BEA value added
// clear
// import delimited "build/input/bea_value_added.csv", varnames(1)
//
// replace value_added = strtrim(value_added)
// replace value_added = "" if value_added == "..."
// destring value_added, replace
//
// // replace category = strrtrim(category)
// drop if strpos(category, "Compensation") > 0
// drop if strpos(category, "Gross") > 0
// drop if strpos(category, "Taxes") > 0
// drop if strpos(category, "[") > 0
//
// gen iorder = _n
//
// gen nspaces = 0
// forvalues i = 1/8 {
// 	replace nspaces = nspaces + 1 if substr(category, `i', 1) == " " & (nspaces == `i' - 1)
// }
// rename nspaces level
// recode level (0 = 1) (4 = 3) (6 = 4) (8 = 5)
//
// drop if (level == 1)
//
// gen detailed = .
// * Drop categories for which finer categories are available
// gen minor = category if (level == 2)
// filldown minor, string
// bysort minor: egen maxlevel = max(level)
// drop if (level == 2) & (maxlevel > 2) & !missing(maxlevel)
// drop maxlevel
//
// sort iorder
// gen broad = category if (level == 3)
// filldown broad if level > 2, string
// bysort broad: egen maxlevel = max(level)
// replace maxlevel = . if missing(broad)
// drop if (level == 3) & (maxlevel > 3) & !missing(maxlevel)
// sort iorder
// drop maxlevel
//
// sort iorder
// gen fine = category if (level == 4)
// filldown fine if level > 3, string
// bysort fine: egen maxlevel = max(level)
// replace maxlevel = . if missing(fine)
// drop if (level == 4) & (maxlevel > 4) & !missing(maxlevel)
// sort iorder
// drop maxlevel
//
//
// //
// // * Drop broad categories for which finer categories are available
// // drop if (level == 3) & (maxlevel > 3)
//
//
//
// * Merge to get NAICS codes
// merge 1:1 name using `naicstmp', keep(1 3)
