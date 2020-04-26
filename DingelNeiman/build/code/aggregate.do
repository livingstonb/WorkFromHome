args socvar force_weighted

* Aggregate up
tempvar missings missing_employment agg_employment all_missing_emp
gen `missings' = missing(employment)
bysort `socvar' sector: egen `missing_employment' = max(`missings')
bysort `socvar' sector: egen `all_missing_emp' = min(`missings')
bysort `socvar' sector: egen `agg_employment' = total(employment), missing

* Compute weighted mean
tempvar tele_weighted agg_teleworkable
gen `tele_weighted' = teleworkable * employment / `agg_employment'
bysort `socvar' sector: egen `agg_teleworkable' = total(`tele_weighted'), missing

* Compute arithmetic mean
tempvar mean_teleworkable
bysort `socvar' sector: egen `mean_teleworkable' = mean(teleworkable)

* Replace with weighted mean first
replace teleworkable = `agg_teleworkable'

if "`force_weighted'" == "force_weighted" {
	* Use arithmetic mean only if employment is missing for entire group
	replace teleworkable = `mean_teleworkable' if `all_missing_emp'
}
else {
	* Use arithmetic mean if any employment is missing for group
	replace teleworkable = `mean_teleworkable' if `missing_employment'
}

* Drop duplicates
duplicates drop `socvar' sector, force
drop `missings' `missing_employment' `agg_employment' `all_missing_emp'
drop `tele_weighted' `agg_teleworkable' `mean_teleworkable' employment
