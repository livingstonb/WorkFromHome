OBJDIRS += ACS/build ACS/stats

sources = build/code/clean_acs.do \
	build/code/read_acs.do \
	stats/code/stats_for_shed.do \
	stats/code/wfh_by_occupation.do

sources := $(addprefix ACS/, $(sources))
includes = $(sources:%.do=%.mk)

targets = build/output/acs_cleaned.dta \
	stats/output/ACSwfh.dta
targets := $(addprefix ACS/, $(targets))

ACS : $(includes) $(targets)

-include $(includes)