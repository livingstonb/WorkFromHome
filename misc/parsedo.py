import os
import sys
import re

def adjustfilename(basedir, ffound):
	if ffound.startswith("../"):
		return ffound.replace("../", "")
	else:
		return os.path.join(basedir, ffound)

def parse(fpath, expr):
	files = []
	basedir = fpath.split(os.sep)[0]
	with open(fpath, 'r') as fobj:
		for line in fobj:
			if expr in line:
				matches = re.findall(r'"(.*?)"', line)
				if len(matches) > 0:
					files.append(
						adjustfilename(basedir, matches[0]))

	if len(files) > 0:
		print(" ".join(files))

fpath = sys.argv[1]
expr = sys.argv [2]

if os.path.isfile(fpath):
	parse(fpath, expr)
else:
	print("File not found")