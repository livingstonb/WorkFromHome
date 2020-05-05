subdir = DingelNeiman

objdirs = build

sources = read_teleworkable.do \
	clean_teleworkable.do \
	prepare_oes.do

targets = build/output/DN_3digit.dta \
	build/output/DN_6digit.dta

empty_targets =

include misc/includes.make