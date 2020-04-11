STATA = ../misc/statab do
SUBS = occupations industries oes acs sipp \
	atus dingelneiman shed merges

.PHONY : clean all $(SUBS)
	
all : $(SUBS)

%.mk : %.do misc/parse_instructions.py
	python misc/parse_instructions.py $< $* $(@D)

include occupations/occupations.make
include industries/industries.make
include OES/oes.make
include ACS/acs.make
include SIPP/sipp.make
include ATUS/atus.make
include DingelNeiman/dingelneiman.make
include SHED/shed.make
include merges/merges.make

cleanlogs :
	rm **/*.log

MYDIR = .
list : $(MYDIR)/*
	for d in $<; do (cd $(d)/build && rm *.mk); done 

cleanmks :
	for d in */; do (cd $(d)/build && rm *.mk); done