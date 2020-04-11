SUBDIRS += 

sources = build/clean_acs.do \
	build/read_acs.do \
	stats/stats_for_shed.do \
	stats/wfh_by_occupation.do

sources := $(addprefix ACS/, $(sources))
includes = $(sources:%.do=%.mk)

targets = build/output/acs_cleaned.dta \
	stats/output/ACSwfh.dta
targets := $(addprefix ACS/, $(targets))

acs : $(includes) $(targets)

-include $(includes)