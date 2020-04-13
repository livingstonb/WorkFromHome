OBJDIRS += occupations/build

types = 2010 2018 SIPP
targets = $(foreach type, $(types), occindex$(type).dta)
targets += $(foreach year, 2010 2018, occ3labels$(year).do)
targets := $(addprefix occupations/build/output/, $(targets))

occupations : $(targets)

targets = occindex2010.dta occ3labels2010.do
targets := $(addprefix occupations/build/output/, $(targets))
objects = occ_soc_2010.txt census_soc_crosswalk_2010.csv
objects := $(addprefix occupations/build/input/, $(objects))
$(targets) : occupations/build/occupation_crosswalk.do $(objects)
	cd occupations && $(STATA) build/occupation_crosswalk.do 2010

targets = occindex2018.dta occ3labels2018.do
targets := $(addprefix occupations/build/output/, $(targets))
objects = occ_soc_2018.txt census_soc_crosswalk_2018.csv
objects := $(addprefix occupations/build/input/, $(objects))
$(targets) : occupations/build/occupation_crosswalk.do $(objects)
	cd occupations && $(STATA) build/occupation_crosswalk.do 2018

targets = occupations/build/output/occindexSIPP.dta
objects = occ_soc_2010.txt census_soc_crosswalk_2010.csv
objects := $(addprefix occupations/build/input/, $(objects))
$(targets) : occupations/build/occupation_crosswalk.do $(objects)
	cd occupations && $(STATA) build/occupation_crosswalk.do SIPP