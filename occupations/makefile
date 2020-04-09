# Variables
OBJDIRS = build/output build/temp
OBJS = occindex2010.dta occindex2018.dta occindexSIPP.dta
OBJS += occ3labels2010.do occ3labels2018.do
OBJS := $(addprefix build/output/, $(OBJS))
DOFILE = build/occupation_crosswalk.do

all : mkdirs $(OBJS)
	rm -rf build/temp

.PHONY : clean all mkdirs

objects = census_soc_crosswalk_2010.csv occ_soc_2010.txt
objects := $(addprefix build/input/, $(objects))
build/output/occindex2010.dta build/output/occ3labels2010.do : $(DOFILE) $(objects)
	../statab do $< 2010

objects = census_soc_crosswalk_2010.csv occ_soc_2010.txt
objects := $(addprefix build/input/, $(objects))
build/output/occindexSIPP.dta : $(DOFILE) $(objects)
	../statab do $< SIPP

objects = census_soc_crosswalk_2018.csv occ_soc_2018.txt
objects := $(addprefix build/input/, $(objects))
build/output/occindex2018.dta build/output/occ3labels2018.do : $(DOFILE) $(objects)
	../statab do $< 2018

include ../misc/mkdirs.mk ../misc/clean.mk