clear

cd "$maindir/other/occ_codes_2010"
import delimited "temp/soc_3digit_map.csv", bindquote(strict)

drop v1

labmask catid, values(category) lblname(category_lbl)
rename fcode soccode
rename catid occ3digit
order soccode occ3digit

keep soccode occ3digit

compress
capture mkdir "$maindir/other/occ_codes_2010/output"
save "$maindir/other/occ_codes_2010/output/occindex2010.dta", replace
