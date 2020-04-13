import sys
import os
import re

def parse_path(fpath):
	paths = dict()
	dirnames = fpath.split("/")
	paths['module'] = dirnames[0]
	paths['subdir'] = os.path.join(*dirnames[:2])
	paths['objdir'] = os.path.join(*dirnames[:3])
	paths['basename'] = os.path.basename(fpath)
	paths['relative'] = os.path.join(*dirnames[1:])
	paths['full'] = fpath

	return paths

def extract_mk(filepath, prefix):
	mk = {	"#DOFILE": [filepath],
			"#PREREQ": [],
			"#TARGET": [],
		}
	with open(filepath, 'r') as fobj:
		for line in fobj:
			for key in mk.keys():
				if key in line:
					matches = re.findall(r'"(.*?)"', line)
					if len(matches) > 0:
						mk[key].append(matches[0])
						break

	for vlist in [mk["#PREREQ"], mk["#TARGET"]]:
		for i in range(len(vlist)):
			if vlist[i].startswith("../"):
				vlist[i] = vlist[i].replace("../", "")
			else:
				vlist[i] = os.path.join(prefix, vlist[i])
	return mk
	
def write_mk(mk, paths):
	do = paths['relative']

	logname = paths['basename'].replace(".do", ".log")
	loginitial = os.path.join(paths['module'], logname)
	logfinal = os.path.join(paths['subdir'], "logs", logname)

	doline = "dofiles = " + " \\\n\t".join(mk["#DOFILE"])
	prereqline = "objects = " + " \\\n\t".join(mk["#PREREQ"])
	targetline = "targets = " + " \\\n\t".join(mk["#TARGET"])

	mkname = paths['full'].replace(".do", ".mk")

	body = "\n".join([doline, prereqline, targetline])
	with open(mkname, 'w') as fobj:
		fobj.write(body + '\n')
		fobj.write("$(targets) : $(dofiles) $(objects)\n")
		fobj.write(f"\tcd {paths['module']} && $(STATA) {do}\n")
		fobj.write(f"\t-mv {loginitial} {logfinal}")

filepath = sys.argv[1]

paths = parse_path(filepath)
mk = extract_mk(filepath, paths['module'])
write_mk(mk, paths)