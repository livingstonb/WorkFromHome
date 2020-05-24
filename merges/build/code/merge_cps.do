
use "build/output/merged5d.dta", clear

tempfile m3d

* Sector C
preserve
#delimit ;
collapse (mean) meanwage_s0 (mean) employment_s0
	[iw=weights_s0], by(soc3d2010);
#delimit cr
save `m3d'
restore

* Sector S
preserve
#delimit ;
collapse (mean) meanwage_s1 (mean) employment_s1
	[iw=weights_s1], by(soc3d2010);
#delimit cr

merge 1:1 soc3d2010 using `m3d', nogen
save `m3d', replace
restore

* Both sectors
#delimit ;
collapse (mean) teleworkable (mean) essential
	[iw=weights_s2], by(soc3d2010);
#delimit cr
merge 1:1 soc3d2010 using `m3d', nogen
save `m3d', replace

* Read CPS data
use "../CPS/build/output/cps_output.dta", clear

* Merge
merge m:1 soc3d2010 using `m3d', nogen

sort soc3d2010 year month

save "build/output/merged_cps.dta", replace
