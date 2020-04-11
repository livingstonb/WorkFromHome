import sys
import os

def check_valid(word):
	return (word.startswith('"') and
		(word.endswith('"') or word.endswith(",")))

def getnames(line):
	words = line.split(" ")
	words = list(filter(check_valid, words))
	if len(words) == 1:
		return words[0].replace('"', '').replace(',', '')


def extract_mk(filepath, prefix):
	mk = {	"#DOFILE": [filepath],
			"#PREREQ": [],
			"#TARGET": [],
		}
	with open(filepath, 'r') as fobj:
		for line in fobj:
			for key in mk.keys():
				if key in line:
					cleaned = getnames(line)
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
	base = os.path.basename(outpath)

	do = "/".join(mk['#DOFILE'][0].split("/")[1:])

	doline = "dofiles = " + " \\\n\t".join(mk["#DOFILE"])
	prereqline = "objects = " + " \\\n\t".join(mk["#PREREQ"])
	targetline = "targets = " + " \\\n\t".join(mk["#TARGET"])

	lines = [doline, prereqline, targetline]
	body = "\n".join(lines) + "\n"
	with open(outpath + ".mk", 'w') as fobj:
		fobj.write(body)
		fobj.write("$(targets) : $(dofiles) $(objects)\n")
		fobj.write(f"\tcd {prefix} && $(STATA) {do}")

filepath = sys.argv[1]
prefix = filepath.split("/")[0]
outpath = sys.argv[2]

mk = extract_mk(filepath, prefix)
write_mk(outpath, mk, prefix)