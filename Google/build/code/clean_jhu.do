
* County summary data
clear
import delimited using "build/input/JHU_counties.csv", varnames(1)

drop if state == "PR"
drop if mod(fips, 1000) == 0

destring icubeds, force replace

rename state statename
rename area_name county

keep statename county fips icubeds

save "build/temp/jhu_summary.dta", replace

* County interventions
clear
import delimited using "build/input/JHU_interventions.csv", varnames(1)

rename v5 gathering_ban_50
rename v6 gathering_ban_500
rename stayathome shelter_in_place
rename publicschools school_closure
rename restaurantdinein dine_in_ban
rename entertainmentgym entertainment_closure
rename federalguidelines federal_guidelines
rename foreigntravelban travel_ban

local jan1960 = 715510

#delimit ;
local policies gathering_ban_50 gathering_ban_500 shelter_in_place
	school_closure dine_in_ban entertainment_closure federal_guidelines
	travel_ban;
#delimit cr

foreach var of local policies {
	destring `var', force replace
	replace `var' = `var' - `jan1960' + 1
	format %td `var'
}

drop state area_name
save "build/temp/jhu_interventions.dta", replace
