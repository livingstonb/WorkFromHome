/* --- HEADER ---
Aggregates the teleworkable measure from a finer occupation classification to a
broader classification. The teleworkable measure is aggregated up using an
employment-weighted mean where possible.

--- Arguments ---
socvar : Variable containing occupation codes for the broader category
televar : Teleworkable measure
new_televar : Desired name of the newly aggregated teleworkable measure
force_weighted : An option argument, that when passed "force_weighted", aggregates
	teleworkable with a weighted mean whenever there is at least one non-missing
	value for employment within the group. Otherwise, if any employment value
	within the group is missing, an unweighted mean is used.
*/


args socvar televar new_televar force_weighted

* Aggregate up
tempvar missings missing_employment agg_employment all_missing_emp
gen `missings' = missing(employment)
bysort `socvar' sector: egen `missing_employment' = max(`missings')
bysort `socvar' sector: egen `all_missing_emp' = min(`missings')
bysort `socvar' sector: egen `agg_employment' = total(employment), missing

* Compute weighted mean
tempvar tele_weighted agg_teleworkable
gen `tele_weighted' = `televar' * employment / `agg_employment'
bysort `socvar' sector: egen `agg_teleworkable' = total(`tele_weighted'), missing

* Compute arithmetic mean
tempvar mean_teleworkable
bysort `socvar' sector: egen `mean_teleworkable' = mean(`televar')

* Use weighted mean first
gen `new_televar' = `agg_teleworkable'

if "`force_weighted'" == "force_weighted" {
	* Use arithmetic mean only if employment is missing for entire group
	replace `new_televar' = `mean_teleworkable' if `all_missing_emp'
}
else {
	* Use arithmetic mean if any employment is missing for group
	replace `new_televar' = `mean_teleworkable' if `missing_employment'
}

* Drop
// duplicates drop `socvar' sector, force
drop `missings' `missing_employment' `agg_employment' `all_missing_emp'
drop `tele_weighted' `agg_teleworkable' `mean_teleworkable'
