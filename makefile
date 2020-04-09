
.PHONY : clean all crosswalks acs sipp atus shed cleanlogs

all : crosswalks acs sipp atus shed

crosswalks :
	make -C occupations
	make -C industries

acs : crosswalks
	make -C ACS

sipp : crosswalks
	make -C SIPP

atus : crosswalks
	make -C ATUS

shed : acs crosswalks
	make -C SHED

cleanlogs :
	rm **/*.log