
.PHONY : clean

all : acs sipp

crosswalks :
	make -C occupations
	make -C industries

acs : crosswalks
	make -C ACS

sipp : crosswalks
	make -C SIPP