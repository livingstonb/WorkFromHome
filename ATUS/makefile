# Variables
OBJDIRS = build/output build/temp stats/output
OBJS = build/output/atus_cleaned.dta

all : mkdirs build_data stats
.PHONY : all clean mkdirs build_data stats

# Build recipes
build_data :
	$(MAKE) build/temp/atus_temp.dta
	$(MAKE) build/output/atus_cleaned.dta

# Read raw data
build/temp/atus_temp.dta : build/read_atus.do
	../statab do $<

# Clean dataset
objects =  build/temp/atus_temp.dta
objects += ../occupations/build/output/occindex2010.dta
objects += ../industries/build/output/industryindex2012.dta
build/output/atus_cleaned.dta : build/clean_atus.do $(objects)
	../statab do $<

# Statistics recipes
stats : build_data
	$(MAKE) stats/output/ATUSwfh.dta

objects = ../ado/statalist.class
objects += ../ado/createxlsx.ado
objects += ../ado/collapse2excel.ado
objects += build/output/atus_cleaned.dta
objects += ../occupations/build/output/occindex2010.dta
stats/output/ATUSwfh.dta : stats/wfh_by_occupation.do $(objects)
	../statab do $<

# Make directories
mkdirs :
	mkdir -p $(OBJDIRS)

# Cleanup
clean :
	rm -rf $(OBJDIRS)
	rm **.log

.PHONY : clean