# Variables
OBJDIRS = build/output
OBJS = industryindex2012.dta industryindex2017.dta naicsindex2017.dta
OBJS := $(addprefix build/output/, $(OBJS))
DOFILE = build/industry_crosswalk.do

all : mkdirs $(OBJS)
.PHONY : clean mkdirs

objects = naics_to_sector.csv ind2012.csv industryindex2017.xlsx
objects := $(addprefix, build/input/, $(objects))
$(OBJS) :  $(DOFILE) $(objects)
	../statab do $<

include ../misc/mkdirs.mk ../misc/clean.mk