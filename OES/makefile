# Variables
OBJDIRS = build stats
OBJS = build/output/oes3d.dta \
	build/output/oes4d.dta \
	stats/output/OESstats.dta

all : $(INCLUDES) mkdirs $(OBJS)

.PHONY : clean all mkdirs

include build/read_oes.mk
include ../misc/includes.mk