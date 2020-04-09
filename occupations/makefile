# Variables
OBJDIRS = build/output build/temp
OBJS = occindex2010.dta occindex2018.dta occindexSIPP.dta
OBJS := $(OBJS) occ3labels2010.do occ3labels2018.do
OBJS := $(addprefix build/output/, $(OBJS))
DOFILE = build/occupation_crosswalk.do

.PHONY : clean

all : $(OBJDIRS) $(OBJS)
	rm -rf build/temp

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

# Make directories
$(OBJDIRS) :
	mkdir -p $(OBJDIRS)

# Cleanup
clean :
	rm -rf $(OBJDIRS)
	rm **.log