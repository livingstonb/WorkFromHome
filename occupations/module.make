objdirs = occupations/build

SUBDIRS += $(objdirs)

newdirs = $(addsuffix /temp, $(objdirs))
newdirs += $(addsuffix /logs, $(objdirs))
newdirs += $(addsuffix /output, $(objdirs))
OBJDIRS += $(newdirs)

codedir = occupations/build/code
src = build/code/occupation_crosswalk.do

newdirs = temp logs output
newdirs := $(addprefix occupations/build/, $(newdirs))

types = 2010 2018 SIPP
targets = $(foreach type, $(types), occindex$(type).dta)
targets += $(foreach year, 2010 2018, occ3labels$(year).do)
targets := $(addprefix occupations/build/output/, $(targets))

targets = occindex2010.dta occ3labels2010.do
targets := $(addprefix occupations/build/output/, $(targets))
objects = occ_soc_2010.txt census_soc_crosswalk_2010.csv
objects := $(addprefix occupations/build/input/, $(objects))
logpath = occupations/build/logs/occupation_crosswalk2010.log
$(targets) : $(codedir)/occupation_crosswalk.do $(objects)
	mkdir -p $(newdirs)
	cd occupations && $(STATA) $(src) 2010
	mv occupations/occupation_crosswalk.log $(logpath)

targets = occindex2018.dta occ3labels2018.do
targets := $(addprefix occupations/build/output/, $(targets))
objects = occ_soc_2018.txt census_soc_crosswalk_2018.csv
objects := $(addprefix occupations/build/input/, $(objects))
logpath = occupations/build/logs/occupation_crosswalk2018.log
$(targets) : $(codedir)/occupation_crosswalk.do $(objects)
	mkdir -p $(newdirs)
	cd occupations && $(STATA) $(src) 2018
	mv occupations/occupation_crosswalk.log $(logpath)

targets = occupations/build/output/occindexSIPP.dta
objects = occ_soc_2010.txt census_soc_crosswalk_2010.csv
objects := $(addprefix occupations/build/input/, $(objects))
objects += occupations/build/output/occ3labels2010.do
logpath = occupations/build/logs/occupation_crosswalkSIPP.log
$(targets) : $(codedir)/occupation_crosswalk.do $(objects)
	mkdir -p $(newdirs)
	cd occupations && $(STATA) $(src) SIPP
	mv occupations/occupation_crosswalk.log $(logpath)

occupations : $(targets)