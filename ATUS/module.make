subdir = ATUS

objdirs = build stats

sources = clean_atus.do read_atus.do \
	wfh_by_occupation.do

targets = build/output/atus_cleaned.dta stats/output/ATUSwfh.dta

empty_targets =

include misc/includes.make