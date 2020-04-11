
OBJDIRS = build

types = 2010 2018 SIPP
OBJS = $(foreach type, $(types), occindex$(type).dta)
OBJS += $(foreach year, 2010 2018, occ3labels$(year).do)
OBJS := $(addprefix build/output/, $(OBJS))

all : $(INCLUDES) mkdirs $(OBJS)

.PHONY : clean all mkdirs

include build/occupation_crosswalk.mk
include ../misc/includes.mk