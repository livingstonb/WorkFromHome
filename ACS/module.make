subdir = ACS

objdirs = build stats

sources = clean_acs.do \
	read_acs.do \
	stats_for_shed.do \
	wfh_by_occupation_stata.do \
	wfh_by_occupation_excel.do

targets = build/output/acs_cleaned.dta \
	stats/output/ACSwfh.dta \
	stats/output/ACS_wfh_yearly.xlsx

empty_targets =

include misc/includes.make