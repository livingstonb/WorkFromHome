subdir = occupations

objdirs = build

sources = make_crosswalk1.do make_crosswalk2.do \
	make_2000_2010_crosswalk.do

targets = build/output/occindex2010.dta \
	build/output/occindex2018.dta \
	build/output/occindexSIPP.dta \
	build/output/occ3labels2010.do

include misc/includes.make