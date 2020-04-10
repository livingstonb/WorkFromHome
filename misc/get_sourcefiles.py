import os
import sys

def get_sourcefiles(dirpaths, suffix):
	matches = ["SOURCES ="]
	for dirpath in dirpaths:
		for file in os.listdir(dirpath):
			if file.endswith(suffix):
				matches.append(os.path.join(dirpath, file))

	return matches

def write_includes(outpath, matches):
	set_includes = "\nINCLUDES = " + \
		"$(patsubst %.do, %.mk, $(SOURCES))"
	with open(outpath, 'w') as fobj:
		fobj.write(" ".join(matches))
		fobj.write(set_includes)


suffix = sys.argv[1]
outpath = sys.argv[2]
dirpaths = sys.argv[3:]

matches = get_sourcefiles(dirpaths, suffix)
write_includes(outpath, matches)