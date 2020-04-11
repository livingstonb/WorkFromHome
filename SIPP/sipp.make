SUBDIRS += SIPP
OBJDIRS += SIPP/build SIPP/stats
sources = build/clean_annual.do build/clean_monthly.do \
	build/combine_waves.do stats/stats.do

sources := $(addprefix SIPP/, $(sources))
includes = $(sources:%.do=%.mk)

targets = build/output/sipp_cleaned.dta \
	stats/output/SIPPwfh.dta
targets := $(addprefix SIPP/, $(targets))

sipp : $(includes) $(targets)

-include $(includes)