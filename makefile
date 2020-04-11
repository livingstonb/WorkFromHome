STATA = ../statab do
SUBS = occupations industries oes acs sipp \
	atus dingelneiman shed

.PHONY : clean all $(SUBS)
	
all : $(SUBS)

%.mk : %.do misc/parse_instructions.py makefile
	python misc/parse_instructions.py $< $* $(@D)

include occupations/occupations.make
include industries/industries.make
include OES/oes.make
include ACS/acs.make
include SIPP/sipp.make
include ATUS/atus.make
include DingelNeiman/dingelneiman.make
include SHED/shed.make

# shed : acs occupations industries
# 	$(MAKE) -C SHED

cleanlogs :
	rm **/*.log

cleanmks :
	rm **/*.mk