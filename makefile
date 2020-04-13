STATA = ../misc/statab do
SUBDIRS = occupations industries OES ACS \
	ATUS DingelNeiman SHED SIPP merges

all : $(SUBDIRS)

%.mk : %.do misc/parse_instructions.py
	python misc/parse_instructions.py $< $*

ifeq (, $(findstring clean, $(MAKECMDGOALS)))
include occupations/occupations.make
include industries/industries.make
include OES/oes.make
include ACS/acs.make
include SIPP/sipp.make
include ATUS/atus.make
include DingelNeiman/dingelneiman.make
include SHED/shed.make
include merges/merges.make
endif

.PHONY : clean all

clean :
	rm -f $(shell find . -name "*.mk")
	rm -f $(shell find . -name "*.log")