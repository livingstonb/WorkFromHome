# Variables
OBJDIRS = build/output build/temp stats/output stats/temp

all : mkdirs build_data compute_stats
.PHONY : all clean mkdirs build_data compute_stats

# Main recipes
build_data : combine_waves clean_monthly clean_annual
compute_stats : build_data stats

include build/combine_waves.mk
include build/clean_monthly.mk
include build/clean_annual.mk
include stats/stats.mk

$(combine_waves_targets) :
	$(MAKE) combine_waves
$(clean_monthly_targets) :
	$(MAKE) clean_monthly
$(clean_annual_targets) :
	$(MAKE) clean_annual
$(stats_targets) :
	$(MAKE) stats

# Read raw data
build/input/sipp_raw_w%.dta : build/read_sipp.do pu2014w%.dta
	../statab do $< $*

# Utilities
include ../misc/mkdirs.mk ../misc/clean.mk

.SECONDEXPANSION:

% :: build/%.do build/%.mk $$(%_objects)
	../statab do $<
	touch $@