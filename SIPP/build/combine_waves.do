// NOTE: FIRST RUN "do macros.do" IN THE MAIN DIRECTORY

/* Dataset: SIPP */
/* This script combines multiple waves for the 2014 SIPP. */

use "$SIPPout/sipp_cleaned_w3.dta", clear
append using "$SIPPout/sipp_cleaned_w4.dta"

/* Create occupation variable that replaces codes unemployed
workers with their occuption in another wave. */
gen occ3adj = occ3d2010
bysort personid: egen monthsworked_all = max(mostmonths)
by personid: gen primaryocc_tmp = occ3d2010 if (mostmonths == monthsworked_max)
by personid (swave): egen primaryocc_all = max(primaryocc_tmp)