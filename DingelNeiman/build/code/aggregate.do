args socvar

* Aggregate up
tempvar missings missing_employment agg_employment
gen `missings' = missing(employment)
bysort `socvar' sector: egen `missing_employment' = max(`missings')
bysort `socvar' sector: egen `agg_employment' = total(employment)
replace `agg_employment' = . if `missing_employment'

* Use weighted mean if employment was present
tempvar tele_weighted agg_teleworkable
gen `tele_weighted' = teleworkable * employment / `agg_employment'
bysort `socvar' sector: egen `agg_teleworkable' = total(`tele_weighted'), missing

* Take mean if employment was missing
tempvar mean_teleworkable
bysort `socvar' sector: egen `mean_teleworkable' = mean(teleworkable)
replace teleworkable = `agg_teleworkable'
replace teleworkable = `mean_teleworkable' if `missing_employment'

* Drop duplicates
duplicates drop `socvar' sector, force
drop `missings' `missing_employment' `agg_employment'
drop `tele_weighted' `agg_teleworkable'
drop `mean_teleworkable' employment