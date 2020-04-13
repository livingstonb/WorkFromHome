SUBDIRS += ATUS
OBJDIRS += ATUS/build ATUS/stats

sources = build/clean_atus.do build/read_atus.do \
	stats/wfh_by_occupation.do

sources := $(addprefix ATUS/, $(sources))
includes = $(sources:%.do=%.mk)

targets = build/output/atus_cleaned.dta stats/output/ATUSwfh.dta
targets := $(addprefix ATUS/, $(targets))

ATUS : $(includes) $(targets)

-include $(includes)