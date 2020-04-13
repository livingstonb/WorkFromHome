OBJDIRS += merges/build

sources = merge_wfh.do make_wide.do
sources := $(addprefix merges/build/, $(sources))
includes = $(sources:%.do=%.mk)

targets = merges/build/output/wfh_merged_wide.dta

merges : $(includes) $(targets)

-include $(includes)