
local options build stats

// OCCUPATION CROSSWALKS
cd occupations
do "main_occupations.do"
cd ..

// INDUSTRY CROSSWALKS
cd industries
do "main_industries.do"
cd ..

// ACS
cd ACS
do "main_acs.do"
cd ..

// ATUS
cd ATUS
do "main_atus.do"
cd ..

// SIPP
cd SIPP
do "main_sipp.do"
cd ..

// OES
cd OES
do "main_oes.do"
cd ..

// Dingel and Neiman
cd DingelNeiman
do "main_dingelneiman.do"
cd ..

// Critical workers
cd CriticalInfrastructure
do "main_critical.do"
cd ..

// Merge
cd merges
do "main_merges.do"
cd ..
