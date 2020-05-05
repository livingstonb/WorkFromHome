subdir = DingelNeiman

objdirs = build

sources = read_teleworkable.do \
	clean_teleworkable.do \
	prepare_oes.do \
	teleworkable_manual_5digit.do

targets = build/output/DN_3digit.dta \
	build/output/DN_6digit.dta \
	build/output/DN_5d_manual_scores.dta

empty_targets =

include misc/includes.make