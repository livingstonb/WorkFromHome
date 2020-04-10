tempdirs = $(addsuffix /temp, $(OBJDIRS))
outdirs = $(addsuffix /output, $(OBJDIRS))

clean :
	rm -rf $(tempdirs) $(outdirs)