OBJDIRS += $(addprefix, $(subdir), $(objdirs))

sources := $(foreach name, $(sources), \
	$(shell find $(subdir) -name $(name) ))
includes = $(sources:%.do=%.mk)
targets := $(addprefix $(subdir)/, $(targets))

$(subdir) : $(includes) $(targets)

-include $(includes)