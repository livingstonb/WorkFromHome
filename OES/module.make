subdir = OES

objdirs = build stats

sources = clean_oes3d.do stats.do

targets = build/output/oes3d.dta \
	build/output/oes4d.dta \
	stats/output/OESstats.dta

objects := OES/build/code/read_oes.do OES/build/input/nat%d_M2017_dl.xlsx
OES/build/output/oes%d.dta : $(objects)
	cd OES && $(STATA) build/code/read_oes.do $*

include misc/includes.make