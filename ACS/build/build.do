// NOTE: FIRST RUN "do macros.do" IN THE MAIN DIRECTORY

// BUILD DATASET
clear
do "$ACSbuild/read.do"
do "$ACSbuild/gen_variables.do"
