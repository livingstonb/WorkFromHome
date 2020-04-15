subdir = ACS

objdirs = build stats

sources = clean_acs.do \
	read_acs.do \
	stats_for_shed.do \
	wfh_by_occupation_stata.do \
	wfh_by_occupation_excel.do

targets = build/output/acs_cleaned.dta \
	stats/output/ACSwfh.dta

include misc/includes.make