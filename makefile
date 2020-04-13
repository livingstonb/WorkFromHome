STATA = ../misc/statab do
SUBDIRS = occupations industries OES ACS \
	SIPP ATUS DingelNeiman SHED merges

all : $(SUBDIRS)

%.mk : %.do misc/parse_instructions.py
	@python misc/parse_instructions.py $< $*

ifeq (, $(findstring clean, $(MAKECMDGOALS)))
include $(addsuffix /module.make, $(SUBDIRS))
endif

.PHONY : clean all

clean :
	rm -f $(shell find . -name "*.mk")
	rm -f $(shell find . -name "*.log")