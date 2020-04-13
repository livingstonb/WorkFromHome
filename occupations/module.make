subdir = occupations

objdirs = build

sources = make_crosswalk1.do make_crosswalk2.do

targets = build/output/occindex2010.dta \
	build/output/occindex2018.dta \
	build/output/occindexSIPP.dta

include misc/includes.make