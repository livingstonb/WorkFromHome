subdir = SHED

objdirs = build stats

sources = clean_shed.do read_shed.do

targets = stats/output/SHED_HtM.xlsx \
	build/output/shed_cleaned.dta

include misc/includes.make