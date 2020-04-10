
use "build/temp/oes4d_temp.dta", clear
adopath + "../ado"

keep if OCC_GROUP == "total"
keep NAICS NAICS_TITLE TOT_EMP

rename TOT_EMP employment
rename NAICS_TITLE naics_title
replace naics_title = strtrim(naics_title)

replace employment = subinstr(employment, "*", "", .)
destring employment, replace

rename NAICS naics4d
replace naics4d = strtrim(naics4d)
replace naics4d = substr(naics4d, 1, 4)
destring naics4d, replace

* Split aggregated industries equally by employment
gen varexpand = naics_title == "Chemical Manufacturing (3251, 3252, 3253, and 3259 only)"
expand_industries naics4d, values(3251 3252 3253 3259) indicator(varexpand) empvar(employment)
drop varexpand

gen varexpand = naics_title == "Chemical Manufacturing (3255 and 3256 only)"
expand_industries naics4d, values(3255 3256) indicator(varexpand) empvar(employment)
drop varexpand

gen varexpand = naics_title == "Fabricated Metal Product Manufacturing (3323 and 3324 only)"
expand_industries naics4d, values(3323 3324) indicator(varexpand) empvar(employment)
drop varexpand

gen varexpand = naics_title == "Fabricated Metal Product Manufacturing (3321, 3322, 3325, 3326, and 3329 only)"
expand_industries naics4d, values(3321 3322 3325 3326 3329) indicator(varexpand) empvar(employment)
drop varexpand

gen varexpand = naics_title == "Machinery Manufacturing (3331, 3332, 3334, and 3339 only)"
expand_industries naics4d, values(3331 3332 3334 3339) indicator(varexpand) empvar(employment)
drop varexpand

gen varexpand = naics_title == "Furniture and Related Product Manufacturing (3371 and 3372 only)"
expand_industries naics4d, values(3371 3372) indicator(varexpand) empvar(employment)
drop varexpand

gen varexpand = naics_title == "Merchant Wholesalers, Durable Goods (4232, 4233, 4235, 4236, 4237, and 4239 only)"
expand_industries naics4d, values(4232 4233 4235 4236 4237 4239) indicator(varexpand) empvar(employment)
drop varexpand

gen varexpand = naics_title == "Merchant Wholesalers, Nondurable Goods (4241, 4247, and 4249 only)"
expand_industries naics4d, values(4241 4247 4249) indicator(varexpand) empvar(employment)
drop varexpand

gen varexpand = naics_title == "Merchant Wholesalers, Nondurable Goods (4244 and 4248 only)"
expand_industries naics4d, values(4244 4248) indicator(varexpand) empvar(employment)
drop varexpand

gen varexpand = naics_title == "Food and Beverage Stores (4451 and 4452 only)"
expand_industries naics4d, values(4451 4452) indicator(varexpand) empvar(employment)
drop varexpand

gen varexpand = naics_title == "Miscellaneous Store Retailers (4532 and 4533 only)"
expand_industries naics4d, values(4532 4533) indicator(varexpand) empvar(employment)
drop varexpand

gen varexpand = naics_title == "Credit Intermediation and Related Activities (5221 And 5223 only)"
expand_industries naics4d, values(5221 5223) indicator(varexpand) empvar(employment)
drop varexpand

gen varexpand = naics_title == "Rental and Leasing Services (5322, 5323, and 5324 only)"
expand_industries naics4d, values(5322 5323 5324) indicator(varexpand) empvar(employment)
drop varexpand

save "build/output/oes4d_cleaned.dta", replace
