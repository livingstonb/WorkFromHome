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

filepath = sys.argv[1]
outpath = sys.argv[2]
(prereqs, targets) = parse_instructions(filepath)

write_instructions(prereqs, targets, outpath)