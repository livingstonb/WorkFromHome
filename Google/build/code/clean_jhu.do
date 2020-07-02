
* County summary data
clear
import delimited using "build/input/JHU_counties.csv", varnames(1)

drop if state == "PR"
drop if mod(fips, 1000) == 0

foreach var of varlist icubeds *tempavgf {
	destring `var', force replace
}

rename state statename
rename area_name county
rename febtempavgf tempf2
rename martempavgf tempf3
rename aprtempavgf tempf4
rename maytempavgf tempf5
rename juntempavgf tempf6

rename percentofadultswithabachelorsdeg share_bachelors
rename pctpovall_2018 share_poverty
rename unemployment_rate_2018 share_unemployed

foreach var of varlist share_* {
	destring `var', force replace
    replace `var' = `var' / 100
}

#delimit ;
foreach var of varlist median_household_income_2018
	total_male total_female total_age65plus total_age85plusr {;
	destring `var', force replace;
};
#delimit cr

gen log_median_income = log(median_household_income_2018)

gen totpop = total_male + total_female
gen share_65plus = total_age65plus / totpop
gen share_85plus = total_age85plusr / totpop
gen share_female = total_female / totpop

keep statename county fips icubeds tempf* share_* log_median_income totpop

* NYC
replace fips = 99991 if inlist(fips, 36081, 36061, 36047, 36005, 36085)

egen tmp_ny_icubeds = total(icubeds) if fips == 99991
replace icubeds = tmp_ny_icubeds if fips == 99991

gen wgts = totpop / 10000
foreach var of varlist tempf* share_* log_median_income {
    quietly sum `var' [aw=wgts] if fips == 99991
	replace `var' = r(mean) if fips == 99991
}
drop wgts totpop

drop if fips == 99991 & county != "Kings County"
replace county = "New York City" if fips == 99991

* Estimate temperature trend
reshape long tempf, i(fips) j(month)

gen day = .
forvalues month = 2/6 {
	local mid_month = date("2020-0`month'-15", "YMD")
	replace day = doy(`mid_month') if month == `month'
}

levelsof statename, local(states)
gen temp_b0 = .
gen temp_b1 = .
foreach state of local states {
	di "`state'"
	
	if inlist("`state'", "UT", "VA", "WA", "WI", "WV", "WY") {
		continue
	}
	quietly reg tempf ibn.fips ibn.fips#c.day if statename == "`state'", noconstant
	
	quietly levelsof fips if statename == "`state'", local(counties)
	foreach county of local counties {
		quietly replace temp_b0 = _b[`county'.fips] if fips == `county'
		quietly replace temp_b1 = _b[`county'.fips#c.day] if fips == `county'
	}
}
keep if month == 2

keep fips icubeds share_* temp_* log_median_income
rename temp_b0 tempf_b0
rename temp_b1 tempf_b1
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
