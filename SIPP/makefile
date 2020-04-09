# Variables
OBJDIRS = build/output build/temp stats/output stats/temp
CLEANED = build/output/sipp_cleaned.dta
OBJS = $(CLEANED) stats/output/SIPPwfh.dta

all : mkdirs build_data stats
.PHONY : all clean mkdirs build_data stats

# Build recipes
build_data :
	$(MAKE) build/temp/sipp_monthly1.dta
	$(MAKE) build/temp/sipp_monthly2.dta
	$(MAKE) build/output/sipp_cleaned.dta

# Read raw data
build/input/sipp_raw_w%.dta : build/read_sipp.do pu2014w%.dta
	../statab do $< $*

# Combine waves
objects = sipp_raw_w1.dta sipp_raw_w2.dta sipp_raw_w3.dta sipp_raw_w4.dta
objects := $(addprefix build/input/, $(objects))
build/temp/sipp_monthly1.dta : build/combine_waves.do $(objects)
	../statab do $<

# Clean monthly data
objects = build/temp/sipp_monthly1.dta
objects = ../occupations/build/output/occindexSIPP.dta
objects += ../industries/build/output/industryindex2012.dta
adofiles = ../ado/rowdistinct.ado
build/temp/sipp_monthly2.dta : build/clean_monthly.do  $(objects) $(adofiles)
	../statab do $<

# Clean and aggregate to annual
$(CLEANED) : build/clean_annual.do build/temp/sipp_monthly2.dta
	../statab do $<

# Statistics recipes
stats : build_data
	$(MAKE) stats/output/SIPPwfh.dta

objects = ../occupations/build/output/occindexSIPP.dta
adofiles = statalist.class createxlsx.ado collapse2excel.ado
adofiles := $(addprefix ../ado/, $(adofiles))
stats/output/SIPPwfh.dta : stats/stats.do $(CLEANED) $(adofiles) $(objects)
	../statab do $<

include ../misc/mkdirs.mk ../misc/clean.mk