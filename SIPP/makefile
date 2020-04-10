# Variables
OBJDIRS = build/output build/temp stats/output stats/temp
STATAB = ../statab do

all : mkdirs build/output/sipp_cleaned.dta stats/output/SIPPwfh.dta

# Build from raw data
ifdef WAVE
rawcmd = "$(MAKE) build/input/sipp_raw_w$(WAVE).dta"
else
rawcmd = $(error raw command requires a 'WAVE' argument)
endif

raw :
	$(rawcmd)


# Includes
include mkfiles_sipp.mk
include $(includes_sipp)

# Read raw data
build/input/sipp_raw_w%.dta : build/read_sipp.do pu2014w%.dta
	../statab do $< $*

.PHONY : all clean mkdirs raw

# Utilities
include ../misc/mkdirs.mk ../misc/clean.mk