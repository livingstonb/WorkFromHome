# Variables
OBJDIRS = build/output build/temp stats/output stats/temp
CLEANED = build/output/sipp_cleaned.dta
OBJS = $(CLEANED) stats/output/SIPPwfh.dta

all : mkdirs build_data
.PHONY : all clean mkdirs build_data stats

include build/combine_waves.mk
include build/clean_monthly.mk
include build/clean_annual.mk

# Build recipes
build_data : combine_waves clean_monthly clean_annual

# Read raw data
build/input/sipp_raw_w%.dta : build/read_sipp.do pu2014w%.dta
	../statab do $< $*

.SECONDEXPANSION:
% :: build/%.do build/%.mk $$(%_objects)
	../statab do $<
	touch @

# Statistics recipes
# stats : build_data
# 	$(MAKE) stats/output/SIPPwfh.dta

# include stats/stats.mk
# $(targets) : stats/stats.do $(objects)
# 	../statab do $<

include ../misc/mkdirs.mk ../misc/clean.mk