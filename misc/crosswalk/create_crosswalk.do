
// 2010 OCC INDEX
use "$WFHshared/occ2010/output/occindex2010new.dta", clear
drop occyear
label variable soc2010 "SOC 2010 fine occupation category"
label variable soc3d2010 "SOC 2010 minor occupation category"

drop if occ3d2010 >= 550
decode occ3d2010, gen(occlabel)

tempfile occtmp
save `occtmp'

// LIST FROM GIANLUCA
clear
import excel "$WFHshared/crosswalk/OccupationalListForDaniel.xlsx", firstrow
drop if missing(occ3d2010)
rename occ3d2010 occlabel
merge 1:m occlabel using `occtmp', keepusing(occcensus) nogen

order occcensus occlabel c_sector_intensive wfh_flexible occ_type
sort occcensus

label variable occcensus "2010 Census occupation code"
label variable occlabel "3-digit occupation category"

save "$WFHshared/crosswalk/occupation_sector_crosswalk.dta", replace
