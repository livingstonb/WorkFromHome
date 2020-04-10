# Variables
OBJDIRS = build
OBJS = occindex2010.dta occindex2018.dta occindexSIPP.dta
OBJS += occ3labels2010.do occ3labels2018.do
OBJS := $(addprefix build/output/, $(OBJS))
SRC = $(occupation_crosswalk.do)

all : $(INCLUDES) mkdirs $(OBJS)

.PHONY : clean all mkdirs

targets = occindex2010.dta occ3labels2010.do
targets := $(addprefix build/output, $(targets))
$(targets) : 

mkdirs:
	mkdir -p $(OBJDIRS)

tempdirs = $(addsuffix /temp, $(OBJDIRS))
outdirs = $(addsuffix /output, $(OBJDIRS))
clean :
	rm -rf $(tempdirs) $(outdirs)