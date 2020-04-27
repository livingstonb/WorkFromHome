subdir = SHED

objdirs = build stats

sources = clean_shed.do read_shed.do summary_stats.do

targets = stats/output/SHED_HtM.xlsx \
	build/output/shed_cleaned.dta

empty_targets =

include misc/includes.make