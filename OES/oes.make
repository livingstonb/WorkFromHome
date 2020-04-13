subdir = OES
objdirs = build stats
sources = clean_oes3d.do stats.do

targets = build/output/oes3d.dta \
	build/output/oes4d.dta \
	stats/output/OESstats.dta

build/output/oes%d.dta : build/read_oes.do build/input/nat%d_M2017_dl.xlsx
	$(STATA) $< $*

include misc/includes.make