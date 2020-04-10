
.PHONY : clean all occupations industries acs sipp atus shed cleanlogs

all : occupations industries acs sipp atus shed

occupations :
	$(MAKE) -C occupations

industries :
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

cleanmks :
	rm **/build/*.mk **/stats/*.mk