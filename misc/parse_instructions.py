import sys
import os

def parse_instructions(filepath):
	prereqs = []
	targets = []
	with open(filepath, 'r') as fobj:
		stage = 0
		for line in fobj:
			if line.startswith("PREREQS"):
				stage = 1
				continue
			elif line.startswith("TARGETS"):
				stage = 2
				continue

			if stage > 0:
				pattern = line.strip()


			if stage == 1:
				prereqs.append(line.strip())
			elif stage == 2:
				if line.startswith("*/"):
					return (prereqs, targets)
				else:
					targets.append(line.strip())

def write_instructions(prereqs, targets, outpath):
	base = os.path.basename(outpath)
	prereqs = base + "_objects = " + " ".join(prereqs)
	targets = base + "_targets = " + " ".join(targets)

	with open(outpath + ".mk", 'w') as fobj:
		fobj.write(prereqs)
		fobj.write('\n')
		fobj.write(targets)

def extract_mk(filepath):
	dofiles = []
	prereqs = []
	targets = []
	with open(filepath, 'r') as fobj:
		for line in fobj:
			if line.startswith("DOFILE"):
				lines = line.split(" ")
				dofiles.append(lines[1].rstrip())
			elif line.startswith("local MAKEREQ"):
				lines = line.split(" ")
				prereqs.append(lines[2].replace('"', '').rstrip())
			elif line.startswith("MAKEREQ"):
				lines = line.split(" ")
				prereqs.append(lines[1].rstrip())
			elif line.startswith("local MAKETARGET"):
				lines = line.split(" ")
				targets.append(lines[2].replace('"', '').rstrip())

	mk = dict()
	mk['dofiles'] = dofiles
	mk['prereqs'] = prereqs
	mk['targets'] = targets
	return mk
	
def write_mk(outpath, mk):
	base = os.path.basename(outpath)

	doline = "dofiles = " + " \\\n\t".join(mk['dofiles'])
	prereqline = "objects = " + " \\\n\t".join(mk['prereqs'])
	targetline = "targets = " + " \\\n\t".join(mk['targets'])

	lines = [doline, prereqline, targetline]
	body = "\n".join(lines)
	with open(outpath + ".mk", 'w') as fobj:
		fobj.write(body)
		fobj.write("\n")
		fobj.write("$(targets) : $(dofiles) $(objects)\n")
		fobj.write("\t$(STATA) $<")

filepath = sys.argv[1]
outpath = sys.argv[2]
# (prereqs, targets) = parse_instructions(filepath)
# write_instructions(prereqs, targets, outpath)

mk = extract_mk(filepath)
write_mk(outpath, mk)