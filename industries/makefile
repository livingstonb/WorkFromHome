# Variables
OBJDIRS = build
OBJS = naicsindex2017.dta industryindex2012.dta industryindex2017.dta \
	industry2017crosswalk.dta bea_value_added_sector.dta \
	essential_industries.dta
OBJS := $(addprefix build/output/, $(OBJS))

all : $(INCLUDES) mkdirs $(OBJS)

.PHONY : clean mkdirs

include ../misc/includes.mk