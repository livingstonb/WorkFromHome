STATA = ../statab do
.PHONY : clean all occupations industries acs sipp

all : occupations industries oes acs sipp atus

%.mk : %.do misc/parse_instructions.py makefile
	python misc/parse_instructions.py $< $* $(@D)

include occupations/occupations.make
include industries/industries.make
include OES/oes.make
include ACS/acs.make
include SIPP/sipp.make
include ATUS/atus.make

# occupations :
# 	$(MAKE) -C occupations

# industries :
# 	$(MAKE) -C industries

# acs : occupations industries
# 	$(MAKE) -C ACS

# sipp : occupations industries
# 	$(MAKE) -C SIPP

# atus : occupations industries
# 	$(MAKE) -C ATUS

# shed : acs occupations industries
# 	$(MAKE) -C SHED

# cleanlogs :
# 	rm **/*.log

# cleanmks :
# 	rm **/*.mka