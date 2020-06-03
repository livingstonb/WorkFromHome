
* County summary data
clear
import delimited using "build/input/JHU_counties.csv", varnames(1)

drop if state == "PR"
drop if mod(fips, 1000) == 0

destring icubeds, force replace

rename state statename
rename area_name county

keep statename county fips icubeds

* NYC
replace fips = 99991 if inlist(fips, 36081, 36061, 36047, 36005, 36085)
egen tmp_ny_icubeds = total(icubeds) if fips == 99991
replace icubeds = tmp_ny_icubeds
drop tmp_ny_icubeds
drop if fips == 99991 & county != "Kings County"

keep fips icubeds
save "build/temp/jhu_summary.dta", replace

* County interventions
clear
import delimited using "build/input/JHU_interventions.csv", varnames(1)

rename v5 jhu_gathering_ban_50
rename v6 jhu_gathering_ban_500
rename stayathome jhu_shelter_in_place
rename publicschools jhu_school_closure
rename restaurantdinein jhu_dine_in_ban
rename entertainmentgym jhu_entertainment_closure
rename federalguidelines jhu_federal_guidelines
rename foreigntravelban jhu_travel_ban

local jan1960 = 715510

#delimit ;
local policies jhu_gathering_ban_50 jhu_gathering_ban_500 jhu_shelter_in_place
	jhu_school_closure jhu_dine_in_ban jhu_entertainment_closure jhu_federal_guidelines
	jhu_travel_ban;
#delimit cr

foreach var of local policies {
	destring `var', force replace
	replace `var' = `var' - `jan1960' + 1
	format %td `var'
}

* Add row for New York City
expand 2 if fips == 36047, gen(NYC)
replace fips = 99991 if NYC
drop NYC

drop state area_name
save "build/temp/jhu_interventions.dta", replace
