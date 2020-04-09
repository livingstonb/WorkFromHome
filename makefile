
.PHONY : clean all crosswalks acs sipp atus shed cleanlogs

all : crosswalks acs sipp atus shed
# 	rm **/build/*.mk **/stats/*.mk

crosswalks :
	$(MAKE) -C occupations
	$(MAKE) -C industries

acs : crosswalks
	$(MAKE) -C ACS

mkfiles = SIPP/build/combine_waves.mk
mkfiles += SIPP/build/clean_monthly.mk
mkfiles += SIPP/build/clean_annual.mk
mkfiles += SIPP/stats/stats.mk
sipp : crosswalks $(mkfiles)
	$(MAKE) -C SIPP

atus : crosswalks
	$(MAKE) -C ATUS

shed : acs crosswalks
	$(MAKE) -C SHED

cleanlogs :
	rm **/*.log

%.mk : %.do
	python ./misc/parse_instructions.py $< $*
