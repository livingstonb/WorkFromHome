import sys
import os

def getnames(line):
	words = line.split(" ")
	for word in words:
		word = word.strip()
		if word.startswith('"') and (
			word.endswith('"') or word.endswith(',')):
			cleaned = word.replace('"', '').replace(',', '')
			return cleaned

def extract_mk(filepath, prefix):
	dofiles = [filepath]
	prereqs = []
	targets = []
	with open(filepath, 'r') as fobj:
		for line in fobj:
			if "#DOFILE" in line:
				cleaned = getnames(line)
				if cleaned is not None:
					dofiles.append(cleaned)
			elif "#PREREQ" in line:
				cleaned = getnames(line)
				if cleaned is not None:
					prereqs.append(cleaned)
			elif "#TARGET" in line:
				cleaned = getnames(line)
				if cleaned is not None:
					targets.append(cleaned)

	for vlist in [prereqs, targets]:
		for i in range(len(vlist)):
			if vlist[i].startswith("../"):
				vlist[i] = vlist[i][3:]
			else:
				vlist[i] = prefix + "/" + vlist[i]

	mk = dict()
	mk['dofiles'] = dofiles
	mk['prereqs'] = prereqs
	mk['targets'] = targets
	return mk
	
def write_mk(outpath, mk, prefix):
	base = os.path.basename(outpath)

	do = "/".join(mk['dofiles'][0].split("/")[1:])

	doline = "dofiles = " + " \\\n\t".join(mk['dofiles'])
	prereqline = "objects = " + " \\\n\t".join(mk['prereqs'])
	targetline = "targets = " + " \\\n\t".join(mk['targets'])

	lines = [doline, prereqline, targetline]
	body = "\n".join(lines)
	with open(outpath + ".mk", 'w') as fobj:
		fobj.write(body)
		fobj.write("\n")
		fobj.write("$(targets) : $(dofiles) $(objects)\n")
		fobj.write(f"\tcd {prefix} && $(STATA) {do}")

filepath = sys.argv[1]
outpath = sys.argv[2]
prefix = sys.argv[3].split("/")[0]

mk = extract_mk(filepath, prefix)
if mk is not None:
	write_mk(outpath, mk, prefix)