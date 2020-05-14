

clear
import delimited "build/input/covid_deaths.csv", varnames(1)

rename date tmp_date
gen date = date(tmp_date, "YMD")
format date %td

drop tmp_date fips

save "build/temp/covid_deaths.dta", replace
