

clear
import delimited "build/input/dine_in_bans.csv", varnames(1)

rename dine_in_ban tmp_dine_in_ban
gen dine_in_ban = date(tmp_dine_in_ban, "YMD")
format dine_in_ban %td

drop tmp_dine_in_ban

save "build/temp/dine_in_bans.dta", replace
