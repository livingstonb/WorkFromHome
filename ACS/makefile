# Variables
OBJDIRS = build/output build/temp stats/output stats/temp

OBJS = build/output/acs_cleaned.dta
OBJS := $(OBJS) stats/output/ACSwfh.dta
OBJS := $(OBJS) stats/output/ACS_wfh_pooled.xlsx
OBJS := $(OBJS) stats/output/ACS_wfh_yearly.xlsx

.PHONY : clean

all : $(OBJDIRS) $(OBJS)

# Read raw data
build/temp/acs_temp.dta : build/read_acs.do build/input/acs_raw.dta
	../statab do $<

# Clean dataset
objects = build/clean_acs.do build/temp/acs_temp.dta
crosswalks = "../occupations/build/output/occindex2010.dta"
crosswalks := $(crosswalks) "../occupations/build/output/occindex2018.dta"
crosswalks := $(crosswalks) "../industries/build/output/industryindex2017.dta"
build/output/acs_cleaned.dta : $(objects) $(crosswalks)
	../statab do $<

# Statistics, WFH by occupation
adofiles = ../ado/statalist.class ../ado/createxlsx.ado ../ado/collapse2excel.ado
objects = stats/wfh_by_occupation.do build/output/acs_cleaned.dta
crosswalks = ../occupations/build/output/occindex2010.dta
stats/output/ACSwfh.dta stats/output/ACS_wfh*.xlsx : $(objects) $(adofiles) $(crosswalks)
	../statab do $<

# Make directories
$(OBJDIRS) :
	mkdir -p $(OBJDIRS)

# Cleanup
clean :
	rm -rf $(OBJDIRS)
	rm **.log