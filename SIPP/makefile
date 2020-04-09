# Variables
OBJDIRS = build/output build/temp stats/output stats/temp
CLEANED = build/output/sipp_cleaned.dta
OBJS = $(CLEANED) stats/output/SIPPwfh.dta
SRC = build/read_sipp.do build/combine_waves.do
SRC += build/clean_monthly.do build/clean_annual.do
SRC += stats/stats.do

all : $(OBJDIRS) $(OBJS)

# Read raw data
build/input/sipp_raw_w%.dta : build/read_sipp.do pu2014w%.dta
	../statab do $< $*

# Combine waves
objects = sipp_raw_w1.dta sipp_raw_w2.dta sipp_raw_w3.dta sipp_raw_w4.dta
objects := $(addprefix build/input/, $(objects))
build/temp/sipp_monthly1.dta : build/combine_waves.do $(objects)
	../statab do $<

# Clean monthly data
crosswalks = ../occupations/build/output/occindexSIPP.dta
crosswalks += ../industries/build/output/industryindex2012.dta
objects = build/clean_monthly.do build/temp/sipp_monthly1.dta
adofiles = ../ado/rowdistinct.ado
build/temp/sipp_monthly2.dta : $(objects) $(crosswalks) $(adofiles)
	../statab do $<

# Clean and aggregate to annual
$(CLEANED) : build/clean_annual.do build/temp/sipp_monthly2.dta
	../statab do $<

# Statistics
crosswalks = ../occupations/build/output/occindexSIPP.dta
adofiles = statalist.class createxlsx.ado collapse2excel.ado
adofiles := $(addprefix ../ado/, $(adofiles))
stats/output/SIPPwfh.dta : stats/stats.do $(CLEANED) $(adofiles) $(crosswalks)
	../statab do $<

# Make directories
$(OBJDIRS) :
	mkdir -p $(OBJDIRS)

# Cleanup
clean :
	rm -rf $(OBJDIRS)
	rm **.log


.PHONY : clean