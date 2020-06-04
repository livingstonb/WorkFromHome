/*
Tests possible instruments for policy dummies.
*/

args date_policy instrument in_sample

// SETUP

* Defaults
// local policy d_dine_in_ban
//
// local instrument gcases

* Macros
// local in_sample sample_until_sip

local vcetype vce(cluster stateid)

// ESTIMATION

* Generate variable
tempvar pvar
gen `pvar' = `date_policy' - date("2020-03-13", "YMD") if date == date("2020-03-19", "YMD")

* Regression
eststo: quietly reg `pvar' `instrument' if `in_sample', `vcetype'
