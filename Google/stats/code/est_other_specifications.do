
drop if weekend

* Manual reg models
estimates clear

* Common coefficients on policies
#delimit ; 
eststo: reg mobility_work cases d_school_closure d_dine_in_ban
	d_non_essential_closure d_shelter_in_place if restr_sample & d_march25, noconstant vce(cluster stateid);
#delimit cr

* Common coefficients on policies, full sample
#delimit ;
eststo: reg mobility_work cases d_school_closure d_dine_in_ban
	d_non_essential_closure d_shelter_in_place, noconstant vce(cluster stateid);
#delimit cr

local states = `" "California" "Georgia" "New Mexico" "New York" "Pennsylvania" "West Virginia" "'
local state: word 1 of `states'
plt_fitted `state', suffix("work") fd(0)

* Add lags and leads for policies
#delimit ;
eststo: reg mobility_work cases d_school_closure Ld_school_closure Fd_school_closure
	d_dine_in_ban Ld_dine_in_ban Fd_dine_in_ban
	d_non_essential_closure Ld_non_essential_closure Fd_non_essential_closure
	d_shelter_in_place Fd_shelter_in_place if restr_sample, noconstant vce(cluster stateid);
#delimit cr

local states = `" "California" "Georgia" "New Mexico" "New York" "Pennsylvania" "West Virginia" "'
local state: word 6 of `states'
plt_fitted `state', suffix("work") fd(0)

* State-specific coefficients on policies
#delimit ;
eststo: reg mobility_work cases i.stateid#c.d_school_closure i.stateid#c.d_dine_in_ban
	i.stateid#c.d_non_essential_closure i.stateid#c.d_shelter_in_place if restr_sample, noconstant vce(cluster stateid);
#delimit cr

* State-specific coefficients on policies, full sample
#delimit ;
eststo: reg mobility_work cases i.stateid#c.d_school_closure i.stateid#c.d_dine_in_ban
	i.stateid#c.d_non_essential_closure i.stateid#c.d_shelter_in_place, noconstant vce(cluster stateid);
#delimit cr

* Latex table creation
local suffix work
local figtitle = cond("`suffix'"=="work", "Workplaces", "Retail and rec")
local type levels

#delimit ;
esttab using "stats/output/other_specifications.tex", 
		replace label compress booktabs not
		keep(cases d_school_closure LD.d_school_closure FD.d_school_closure
		d_dine_in_ban LD.d_dine_in_ban FD.d_dine_in_ban
		d_non_essential_closure LD.d_non_essential_closure FD.d_non_essential_closure
		d_shelter_in_place FD.d_shelter_in_place)
		r2 ar2 scalars(N)
		mtitles("W/O leads/lags, date LE SIP" "With leads/lags, date LE SIP" "W/O leads/lags, full sample" "With leads/lags, full sample")
		title("`figtitle', `type'");
#delimit cr
//  "State-specific, date le SIP" "State-specific, full sample"

//
// * Add lags and leads for policies
// #delimit ;
// eststo: reg mobility_work cases i.stateid#c.d_school_closure i.stateid#c.LD.d_school_closure i.stateid#c.FD.d_school_closure
// 	i.stateid#c.d_dine_in_ban i.stateid#c.LD.d_dine_in_ban i.stateid#c.FD.d_dine_in_ban
// 	i.stateid#c.d_non_essential_closure i.stateid#c.LD.d_non_essential_closure i.stateid#c.FD.d_non_essential_closure
// 	i.stateid#c.d_shelter_in_place i.stateid#c.FD.d_shelter_in_place if restr_sample, noconstant vce(cluster stateid);
// #delimit cr
