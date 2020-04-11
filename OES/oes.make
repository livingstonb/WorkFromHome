SUBDIRS += OES
OBJDIRS += OES/build OES/stats

sources = build/clean_oes3d.do \
	stats/stats.do
sources := $(addprefix OES/, $(sources))
includes = $(sources:%.do=%.mk)

targets = build/output/oes3d.dta \
	build/output/oes4d.dta \
	stats/output/OESstats.dta
targets := $(addprefix OES/, $(targets))

oes : $(includes) $(targets)

build/output/oes%d.dta : build/read_oes.do build/input/nat%d_M2017_dl.xlsx
	$(STATA) $< $*

-include $(includes)