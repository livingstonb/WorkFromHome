STATA = ../misc/statab do
MODULES = occupations industries OES ACS \
	SIPP ATUS DingelNeiman SHED merges
SUBDIRS =
OBJDIRS =

all : $(MODULES)

%.mk : %.do misc/parse_instructions.py
	python misc/parse_instructions.py $<

ifeq (, $(findstring clean, $(MAKECMDGOALS)))
include $(addsuffix /module.make, $(MODULES))
endif

.PHONY : clean all

clean :
	rm -f $(shell find . -name "*.mk")
	rm -f $(shell find . -name "*.log")

%/temp :
	mkdir -p $@

%/output :
	mkdir -p $@

%/logs :
	mkdir -p $@