/* --- HEADER ---
This do-file reads the OES 2-, 3-, or 4-digit industry data from excel into
Stata.
*/

args year
import excel "build/input/nat`DIGITdYEAR", clear firstrow

compress
save "build/temp/oes`year'.dta", replace
