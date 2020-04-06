// NOTE: FIRST RUN "do macros.do" IN THE MAIN DIRECTORY

/* Dataset: SHED */
/* This do-file computes summary statistics for SHED. */

clear
use "$SHEDout/SHED.dta"

// SAMPLE SELECTION
keep if (age >= 15)
