preserve
collapse $vlist [iw=perwt], by($bylist) fast

export excel $xlxpath, firstrow(varlabels) replace
restore
