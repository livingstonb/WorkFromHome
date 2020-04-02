// NOTE: FIRST RUN "do macros.do" IN THE MAIN DIRECTORY

/* Dataset: ATUS */
/* This script cleans the dataset for the ATUS 2017-2018. */

do "$ATUSbuild/read.do"
do "$ATUSbuild/clean.do"
