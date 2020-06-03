/*
Tests possible instruments for policy dummies.
*/

// clear
// quietly do "stats/code/prepare_counties_data.do"

* Set options
local policy d_dine_in_ban

local instrument gcases
* Macros
local in_sample sample_until_sip

local vcetype vce(cluster stateid)

* Regression
reg `policy' `instrument' if `in_sample', `vcetype'
