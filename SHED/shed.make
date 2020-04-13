OBJDIRS += SHED/build SHED/stats
sources = build/clean_shed.do build/read_shed.do
sources := $(addprefix SHED/, $(sources))
includes = $(sources:%.do=%.mk)

targets = SHED/stats/output/SHED_HtM.xlsx \
	SHED/build/output/shed_cleaned.dta

SHED : $(includes) $(targets)

-include $(includes)