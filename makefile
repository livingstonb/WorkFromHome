MODULES := occupations industries OES ACS \
	SIPP ATUS DingelNeiman SHED merges BEA \
	Google OpenTable CriticalInfrastructure

.PHONY: all clean backup readme tex

all : readme tex

clean :
	rm -rf $(shell find . -depth -name "output")
	rm -rf $(shell find . -depth -name "temp")
	rm -rf $(shell find . -depth -name "logs")

objdirs = $(shell find . -depth -name "output")
objdirs += $(shell find . -depth -name "temp")
objdirs := $(subst ./, , $(objdirs))
backup :
	-mkdir backup
	for d in $(MODULES) ; do \
		mkdir backup/$$d ;\
		mkdir backup/$$d/build ;\
		mkdir backup/$$d/stats ;\
	done

	echo $(objdirs)
	for d in $(objdirs) ; do \
		cp -r $$d  backup/$$d ;\
	done

readme :
	-pandoc readme.md -o readme.pdf

texloc = tex/data_methods/data_methods
texexts = .aux .bbl .blg .log .out .pdf
texfiles := $(addprefix $(texloc), texexts)
tex :
	rm -f $(texfiles)
	cd tex/data_methods && pdflatex data_methods
	cd tex/data_methods && bibtex data_methods
	cd tex/data_methods && pdflatex data_methods
	cd tex/data_methods && pdflatex data_methods