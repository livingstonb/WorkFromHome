

args R2 yvals yhat tag

tempvar meany
bysort stateid: egen `meany' = mean(`yvals') if `tag'

tempvar sq_res sq_tot ss_res ss_tot

gen `sq_res' = (`yvals' - `yhat') ^ 2 if `tag'
gen `sq_tot' = (`yvals' - `meany') ^ 2 if `tag'
bysort stateid: egen `ss_res' = total(`sq_res')
bysort stateid: egen `ss_tot' = total(`sq_tot')

gen `R2' = 1 - `ss_res' / `ss_tot'
