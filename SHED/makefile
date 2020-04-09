# Variables
OBJDIRS = build/output build/temp stats/output stats/temp
OBJS = build/output/acs_cleaned.dta

all : mkdirs build_data stats
.PHONY : all clean mkdirs build_data stats

# Build recipes
build_data :
	$(MAKE) build/temp/shed_temp.dta
	$(MAKE) build/output/shed_cleaned.dta

# Read raw data
build/temp/shed_temp.dta : build/read_shed.do
	../statab do $<

# Clean dataset
objects = build/temp/shed_temp.dta
objects += build/input/occ_crosswalk.csv
objects += ../industries/build/output/naicsindex2017.dta
objects += ../ACS/stats/output/acs_stats_for_shed.dta
build/output/shed_cleaned.dta : build/clean_shed.do $(objects)
	../statab do $<

# Statistics recipes
stats : build_data
	$(MAKE) stats/output/SHED_HtM.xlsx

objects = ../ado/statalist.class
objects += ../ado/createxlsx.ado
objects += ../ado/collapsecustom.ado
objects += ../ado/collapsevar.class
objects += build/output/shed_cleaned.dta
stats/output/SHED_HtM.xlsx : stats/summary_stats.do $(objects)
	../statab do $<

# Make directories
mkdirs :
	mkdir -p $(OBJDIRS)

# Cleanup
clean :
	rm -rf $(OBJDIRS)
	rm **.log