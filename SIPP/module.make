subdir = SIPP

objdirs = build stats

sources = clean_annual.do \
	clean_monthly.do \
	combine_waves.do \
	stats_excel.do \
	stats_stata.do

targets = build/output/sipp_cleaned.dta \
	stats/output/SIPPwfh.dta

include misc/includes.make