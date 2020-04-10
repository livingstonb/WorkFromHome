
.PHONY : clean all crosswalks acs sipp atus shed cleanlogs

all : crosswalks acs sipp atus shed

cleanmks :
	rm **/build/*.mk **/stats/*.mk

crosswalks :
	$(MAKE) -C occupations
	$(MAKE) -C industries

acs : crosswalks
	$(MAKE) -C ACS

sipp : crosswalks
	$(MAKE) -C SIPP

atus : crosswalks
	$(MAKE) -C ATUS

shed : acs crosswalks
	$(MAKE) -C SHED

cleanlogs :
	rm **/*.log

%.mk : %.do
	python ./misc/parse_instructions.py $< $*
