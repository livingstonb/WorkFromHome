subdir = OES

objdirs = build stats

sources = clean_oes3d2017.do stats2017.do \
	stats_by_occupation.do

targets = stats/output/OESstats.dta \
	stats/output/occupation_level_employment.dta

include misc/includes.make