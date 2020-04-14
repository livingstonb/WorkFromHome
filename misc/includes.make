objdirs := $(addprefix $(subdir)/, $(objdirs))
SUBDIRS += $(objdirs)

newdirs := $(addsuffix /temp, $(objdirs))
newdirs += $(addsuffix /logs, $(objdirs))
newdirs += $(addsuffix /output, $(objdirs))
OBJDIRS += $(newdirs)

sources := $(foreach name, $(sources), \
	$(shell find $(subdir) -name $(name) ))

includes := $(sources:%.do=%.mk)

targets := $(addprefix $(subdir)/, $(targets))

$(subdir) : mkdirs $(includes) $(targets)

-include $(includes)