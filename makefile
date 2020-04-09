
.PHONY : clean all crosswalks acs sipp atus shed cleanlogs

all : crosswalks acs sipp atus shed
# 	rm **/build/*.mk **/stats/*.mk

crosswalks :
	make -C occupations
	make -C industries

acs : crosswalks
	make -C ACS

mkfiles = SIPP/build/combine_waves.mk
mkfiles += SIPP/build/clean_monthly.mk
mkfiles += SIPP/build/clean_annual.mk
mkfiles += SIPP/stats/stats.mk
sipp : crosswalks $(mkfiles)
	make -C SIPP

atus : crosswalks
	make -C ATUS

shed : acs crosswalks
	make -C SHED

cleanlogs :
	rm **/*.log

%.mk : %.do
	python ./misc/parse_instructions.py $< $*
