subdir = OES

objdirs = build stats

sources = stats2017.do stats_by_occupation.do

targets = stats/output/OESstats.dta \
	stats/output/occupation_level_employment.dta

empty_targets =

include misc/includes.make