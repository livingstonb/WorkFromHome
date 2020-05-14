

args R2 yvals yhat

tempvar meany
bysort stateid date: egen `meany' = mean(`yvals')

tempvar sq_res sq_tot ss_res ss_tot

gen `sq_res' = (`yvals' - `yhat') ^ 2
gen `sq_tot' = (`yvals' - `meany') ^ 2
bysort stateid: egen `ss_res' = total(`sq_res')
bysort stateid: egen `ss_tot' = total(`sq_tot')

gen `R2' = 1 - `ss_res' / `ss_tot'
