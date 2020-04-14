STATA = ../misc/statab do
MODULES := occupations industries OES ACS \
	SIPP ATUS DingelNeiman SHED merges
SUBDIRS :=
OBJDIRS :=

all : $(MODULES) readme

all_with_procedures : procedures all

%.mk : %.do misc/make_tools.py
	@python misc/make_tools.py $<

ifeq (, $(findstring clean, $(MAKECMDGOALS)))
include $(addsuffix /module.make, $(MODULES))
endif

.PHONY : clean clean_mk clean_temp clean_output all mkirs \
	clean_module procedures clean_procedures \
	all_with_procedures readme tex

tex :
	rm -f tex/data_methods/data_methods.aux
	rm -f tex/data_methods/data_methods.bbl
	rm -f tex/data_methods/data_methods.blg
	rm -f tex/data_methods/data_methods.log
	rm -f tex/data_methods/data_methods.out
	rm -f tex/data_methods/data_methods.pdf
	cd tex/data_methods && pdflatex data_methods
	cd tex/data_methods && bibtex data_methods
	cd tex/data_methods && pdflatex data_methods
	cd tex/data_methods && pdflatex data_methods

clean : clean_mk clean_temp clean_output clean_procedures

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