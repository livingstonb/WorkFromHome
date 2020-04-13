STATA = ../misc/statab do
MODULES := occupations industries OES ACS \
	SIPP ATUS DingelNeiman SHED merges
SUBDIRS :=
OBJDIRS :=

all : mkdirs $(MODULES)

%.mk : %.do misc/parse_instructions.py
	@python misc/parse_instructions.py $<

ifeq (, $(findstring clean, $(MAKECMDGOALS)))
include $(addsuffix /module.make, $(MODULES))
endif

.PHONY : clean clean_mk clean_temp clean_output all mkirs

mkdirs :
	@mkdir -p $(OBJDIRS)

clean : clean_mk clean_temp clean_output

clean_mk :
	rm -f $(shell find . -name "*.mk")

clean_logs :
	rm -f $(shell find . -name "*.log")
	rm -rf $(shell find . -depth -name "logs")

clean_temp :
	rm -rf $(shell find . -depth -name "temp")

clean_output :
	rm -rf $(shell find . -depth -name "output")

%/temp %/output %/logs:
	mkdir -p $@