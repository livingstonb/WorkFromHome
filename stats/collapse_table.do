preserve

$collapse_commands
global collapse_commands

drop if missing($bylist)
collapse $vlist [iw=perwt], by($bylist) fast

export excel $xlxpath, firstrow(varlabels) replace keepcellfmt
restore