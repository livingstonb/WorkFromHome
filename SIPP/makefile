# Variables
OBJDIRS = build/output build/temp stats/output stats/temp

all : mkdirs build_data compute_stats

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

# Main recipes
build_data : $(buildroutines_sipp)
compute_stats : build_data $(statsroutines_sipp)

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

.PHONY : all clean mkdirs raw

# Utilities
include ../misc/mkdirs.mk ../misc/clean.mk ../misc/mkrule.mk