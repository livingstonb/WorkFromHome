STATA = ../misc/statab do
MODULES := occupations industries OES ACS \
	SIPP ATUS DingelNeiman SHED merges BEA
SUBDIRS :=
OBJDIRS :=

all : $(MODULES) readme

%.mk : %.do misc/make_tools.py
	@python misc/make_tools.py $<

ifeq (, $(findstring clean, $(MAKECMDGOALS)))
include $(addsuffix /module.make, $(MODULES))
endif

.PHONY : clean clean_mk clean_temp clean_output all mkirs \
	clean_module procedures clean_procedures \
	all_with_procedures readme tex

clean : clean_logs clean_mk clean_temp \
	clean_output clean_procedures

clean_mk :
	rm -f $(shell find . -name "*.mk")

clean_logs :
	rm -f $(shell find . -name "*.log")
	rm -rf $(shell find . -depth -name "logs")

clean_temp :
	rm -rf $(shell find . -depth -name "temp")

clean_output :
	rm -rf $(shell find . -depth -name "output")

clean_procedures :
	rm -rf misc/procedures

procedures = $(addprefix misc/procedures/, $(MODULES))
procedures := $(addsuffix .txt, $(procedures))
procedures : clean $(procedures)

misc/procedures/%.txt :
	mkdir -p misc/procedures
	$(MAKE) $* --dry-run | python misc/list_do_tasks.py > $@

readme :
	pandoc readme.md -o readme.pdf

include tex/module.make