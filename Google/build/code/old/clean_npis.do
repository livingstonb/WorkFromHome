
adopath + "../ado"

clear
import delimited "build/input/complete_npis_raw_policies.csv", varnames(1)

drop if strlen(county) > 0

gen date = date(start_date, "MDY")
format date %td
drop start_date end_date citation note county fip_code

#delimit ;
keep if inlist(npi,
	"shelter_in_place", "school_closure", "non-essential_services_closure");
#delimit cr

replace npi = "non_essential_closure" if npi == "non-essential_services_closure"

rename date date_
reshape wide date_, i(state) j(npi) string

rename date_non_essential_closure non_essential_closure
rename date_school_closure school_closure
rename date_shelter_in_place shelter_in_place

save "build/temp/cleaned_npis.dta", replace
