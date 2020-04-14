subdir = OES

objdirs = build stats

sources = clean_oes3d.do stats2017.do read_oes.do \
	compute_occupation_stats.do combine_occupation_stats.do

targets = stats/output/OESstats.dta \
	stats/output/occupation_level_employment.dta

include misc/includes.make
