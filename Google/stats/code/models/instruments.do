/*
Tests possible instruments for policy dummies.
*/

#delimit ;
local policies dine_in_ban school_closure non_essential_closure
	shelter_in_place;
	
	// jhu_dine_in_ban jhu_school_closure;
	// jhu_entertainment jhu_shelter_in_place;

local instruments icubeds rural popdensity;
#delimit cr

local in_sample sample_until_sip

foreach policy of local policies {
	estimates clear
foreach instrument of local instruments {
	do "stats/code/iv_first_stage.do" `policy' `instrument' `in_sample'
	estimates table
}
}
