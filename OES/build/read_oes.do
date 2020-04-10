/* --- HEADER ---
This do-file reads the OES 3- or 4-digit industry data from excel into stata
and resaves.

MAKE
output/oes%d.dta : read_oes.do input/nat%d_M2017_dl.xlsx
	$(STATA) $<
END
*/

args digit
import excel "build/input/nat`digit'd_M2017_dl.xlsx", clear firstrow

compress
save "build/output/oes`digit'd.dta", replace