OBJDIRS += DingelNeiman/build

sources = build/build.do build/aggregate_occs.do
sources := $(addprefix DingelNeiman/, $(sources))
includes = $(sources:%.do=%.mk)

targets = DingelNeiman/build/output/DN_aggregated.dta

DingelNeiman : $(includes) $(targets)

-include $(includes)