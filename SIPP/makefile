# Variables
OBJDIRS = build stats
OBJS = build/output/sipp_cleaned.dta stats/output/SIPPwfh.dta

all : $(INCLUDES) mkdirs $(OBJS)

# Read raw data
ifdef WAVE
rawcmd = "$(MAKE) build/input/sipp_raw_w$(WAVE).dta"
else
rawcmd = $(error raw command requires a 'WAVE' argument)
endif

raw :
	$(rawcmd)

build/input/sipp_raw_w%.dta : build/read_sipp.do pu2014w%.dta
	../statab do $< $*

.PHONY : clean mkdirs raw

include ../misc/includes.mk