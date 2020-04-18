subdir = occupations

objdirs = build

sources = make_crosswalk1.do make_crosswalk2.do \
	occ2010_to_soc3d2010.do \
	oes99_to_soc3d2010.do \
	soc98_to_soc3d2010.do \
	soc2000_to_soc3d2010.do

targets = build/output/occindex2010.dta \
	build/output/occindex2018.dta \
	build/output/occindexSIPP.dta \
	build/output/occ3labels2010.do

include misc/includes.make