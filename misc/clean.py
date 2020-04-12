import os
import sys
def clean(basedir, suffix):
	for root, dirs, files in os.walk(basedir):
		for file in files:
			if file.endswith(suffix):
				fpath = os.path.join(root, file)
				os.remove(fpath)


basedir = sys.argv[1]
suffix = sys.argv [2]

if suffix.startswith(".") and os.path.isdir(basedir):
	clean(basedir, suffix)