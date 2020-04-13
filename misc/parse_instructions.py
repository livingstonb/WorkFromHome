import sys
import os
import re

def extract_name(line):
	matches = re.findall(r'"(.*?)"', line)
	if len(matches) > 0:
		return matches[0]

def extract_mk(filepath, prefix):
	mk = {	"#DOFILE": [filepath],
			"#PREREQ": [],
			"#TARGET": [],
		}
	with open(filepath, 'r') as fobj:
		for line in fobj:
			for key in mk.keys():
				if key in line:
					cleaned = extract_name(line)
					if cleaned is not None:
						mk[key].append(cleaned)
						break

	for vlist in [mk["#PREREQ"], mk["#TARGET"]]:
		for i in range(len(vlist)):
			if vlist[i].startswith("../"):
				vlist[i] = vlist[i].replace("../", "")
			else:
				vlist[i] = os.path.join(prefix, vlist[i])
	return mk
	
def write_mk(outpath, mk, prefix):
	do = "/".join(mk['#DOFILE'][0].split("/")[1:])

	doline = "dofiles = " + " \\\n\t".join(mk["#DOFILE"])
	prereqline = "objects = " + " \\\n\t".join(mk["#PREREQ"])
	targetline = "targets = " + " \\\n\t".join(mk["#TARGET"])

	body = "\n".join([doline, prereqline, targetline])
	with open(outpath + ".mk", 'w') as fobj:
		fobj.write(body + '\n')
		fobj.write("$(targets) : $(dofiles) $(objects)\n")
		fobj.write(f"\tcd {prefix} && $(STATA) {do}")

filepath = sys.argv[1]
prefix = filepath.split("/")[0]
outpath = sys.argv[2]

mk = extract_mk(filepath, prefix)
write_mk(outpath, mk, prefix)