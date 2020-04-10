
.PHONY : clean all crosswalks acs sipp atus shed cleanlogs

all : crosswalks acs sipp atus shed
# 	rm **/build/*.mk **/stats/*.mk

crosswalks :
	$(MAKE) -C occupations
	$(MAKE) -C industries

acs : crosswalks
	$(MAKE) -C ACS

include SIPP/mkfiles_sipp.mk
includes_sipp := $(addprefix SIPP/, $(includes_sipp))
sipp : crosswalks $(includes_sipp)
	$(MAKE) -C SIPP

atus : crosswalks
	$(MAKE) -C ATUS

shed : acs crosswalks
	$(MAKE) -C SHED

cleanlogs :
	rm **/*.log

%.mk : %.do
	python ./misc/parse_instructions.py $< $*
