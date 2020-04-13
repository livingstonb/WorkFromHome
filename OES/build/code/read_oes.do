/* --- HEADER ---
This do-file reads the OES 3- or 4-digit industry data from excel into stata
and resaves.
*/

args DIGITdYR
import excel "build/input/nat`DIGITdYR'", clear firstrow

compress
`#TARGET' save "build/output/oes`DIGITdYR'.dta", replace
