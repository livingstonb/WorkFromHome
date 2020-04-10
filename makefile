
.PHONY : clean all occupations industries acs sipp atus shed cleanlogs

all : occupations industries acs sipp atus shed

occupations :
	$(MAKE) -C occupations

industries :
	$(MAKE) -C industries

acs : occupations industries
	$(MAKE) -C ACS

sipp : occupations industries
	$(MAKE) -C SIPP

atus : occupations industries
	$(MAKE) -C ATUS

shed : acs occupations industries
	$(MAKE) -C SHED

cleanlogs :
	rm **/*.log

cleanmks :
	rm **/build/*.mk **/stats/*.mk