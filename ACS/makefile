# Variables
OBJDIRS = build/output build/temp stats/output stats/temp
OBJS = build/output/acs_cleaned.dta

all : mkdirs build_data stats
.PHONY : all clean mkdirs build_data stats

# Build recipes
build_data :
	$(MAKE) build/temp/acs_temp.dta
	$(MAKE) build/output/acs_cleaned.dta

# Read raw data
build/temp/acs_temp.dta : build/read_acs.do build/input/acs_raw.dta
	../statab do $<

# Clean dataset
objects = build/temp/acs_temp.dta
objects += ../occupations/build/output/occindex2010.dta
objects += ../occupations/build/output/occindex2018.dta
objects += ../industries/build/output/industryindex2017.dta
build/output/acs_cleaned.dta : build/clean_acs.do $(objects)
	../statab do $<

# Statistics recipes
stats : build_data
	$(MAKE) stats/output/ACSwfh.dta
	$(MAKE) stats/output/acs_stats_for_shed.dta

objects = ../ado/statalist.class
objects += ../ado/createxlsx.ado
objects += ../ado/collapse2excel.ado
objects += build/output/acs_cleaned.dta
objects += ../occupations/build/output/occindex2010.dta
stats/output/ACSwfh.dta : stats/wfh_by_occupation.do $(objects)
	../statab do $<

objects = build/output/acs_cleaned.dta
stats/output/acs_stats_for_shed.dta : stats/stats_for_shed.do
	../statab do $<

include ../misc/mkdirs.mk ../misc/clean.mk