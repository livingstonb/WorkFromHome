
// Prepare OES 6-digit occs for merge
import excel "../OES/build/input/nat3d2017", clear firstrow

* Clean
`#PREREQ' do "../OES/build/code/clean_oes_generic.do" 2017

* Merge with sector
`#PREREQ' do "../OES/build/code/merge_with_sector.do"

`#TARGET' save "build/temp/nat3d2017.dta", replace
