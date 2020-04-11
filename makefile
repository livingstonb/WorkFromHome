STATA = ../misc/statab do
SUBDIRS =
TEMPDIRS =
SUBS = occupations industries oes acs sipp \
	atus dingelneiman shed merges

.PHONY : clean all $(SUBS)
	
all : $(SUBS)

%.mk : %.do misc/parse_instructions.py
	python misc/parse_instructions.py $< $*

include occupations/occupations.make
include industries/industries.make
include OES/oes.make
include ACS/acs.make
include SIPP/sipp.make
include ATUS/atus.make
include DingelNeiman/dingelneiman.make
include SHED/shed.make
include merges/merges.make

TEMPDIRS = $(foreach dir, $(OBJDIRS), $(dir)/temp)
OUTDIRS = $(foreach dir, $(OBJDIRS), $(dir)/output)

cleanmks :
	rm -f $(foreach dir, $(OBJDIRS), $(wildcard $(dir)/*.mk))

cleanlogs :
	rm -f $(foreach dir, $(SUBDIRS), $(wildcard $(dir)/*.log))