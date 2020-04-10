# Variables
OBJDIRS = build/output build/temp stats/output stats/temp
OBJS = build/output/sipp_cleaned.dta stats/output/SIPPwfh.dta
STATA = ../statab do

buildnames = combine_waves.mk clean_monthly.mk clean_annual.mk
buildnames := $(addprefix build/, $(buildnames))
INCLUDES = $(buildnames) stats/stats.mk

all : $(INCLUDES) mkdirs $(OBJS)

# Utilities
include ../misc/mkdirs.mk ../misc/clean.mk ../misc/mkrule.mk

# Includes
include $(INCLUDES)

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

.PHONY : all clean mkdirs raw