subdir = OES

objdirs = build stats

sources = clean_oes3d.do stats.do read_oes.do

targets = build/output/oes3d.dta \
	build/output/oes4d.dta \
	stats/output/OESstats.dta

include misc/includes.make