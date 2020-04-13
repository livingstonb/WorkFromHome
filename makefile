STATA = ../misc/statab do
SUBDIRS = occupation sindustries OES ACS \
	ATUS DingelNeiman SHED merges
TEMPDIRS =

.PHONY : clean all cleanmks cleanlogs
	
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

cleanup : cleanmks cleanlogs

cleanmks :
	rm -f $(foreach dir, $(OBJDIRS), $(wildcard $(dir)/*.mk))

cleanlogs :
	rm -f $(foreach dir, $(SUBDIRS), $(wildcard $(dir)/*.log))