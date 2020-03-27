
use "$build/cleaned/acs_cleaned.dta", clear

* Number of observations by year
quietly tab year, matcell(counts) matrow(names)
quietly tab year [iw=perwt], matcell(counts_wt)

putexcel set "$statsout/counts.xlsx", replace
putexcel A1=("Year") B1=("Obs, unweighted") C1=("Obs, weighted")
putexcel A2 = matrix(names, counts, counts_wt)