"""
Parses do-files for prerequisites and targets of the given
source file. Writes a file with extension .mk for the do-file
passed, creating and rule for associated with the do-file that
can then be included in a makefile.

Each line is searched for the presence of #PREREQ or #TARGET,
and the first filename surrounded by double quotes is included
as a prerequisite or target.
"""

import sys
import os
import re

def parse_path(fpath):
	"""
	Extracts different variables associated with filepath.
	"""
	paths = dict()
	dirnames = fpath.split("/")
	paths['module'] = dirnames[0]
	paths['subdir'] = os.path.join(*dirnames[:2])
	paths['objdir'] = os.path.join(*dirnames[:3])
	paths['basename'] = os.path.basename(fpath)
	paths['relative'] = os.path.join(*dirnames[1:])
	paths['full'] = fpath

	return paths

def parse_line(key, line, argName):
	"""
	Looks for the key within a line, and returns
	the matching prerequisite or target, if found.
	Otherwise returns None. If the do-file accepts
	an argument, the argument macro is replaced with %.
	"""
	if key in line:
		matches = re.findall(r'"(.*?)"', line)
		if len(matches) > 0:
			match = matches[0]
			if argName is None:
				return match
			else:
				return match.replace(argName, "%")
	else:
		return None

def adjust_paths(prefix, paths):
	"""
	Strips ../ if present, otherwise appends the base
	directory.
	"""
	for i in range(len(paths)):
		if paths[i].startswith("../"):
			paths[i] = paths[i].replace("../", "")
		else:
			paths[i] = os.path.join(prefix, paths[i])

	return paths

def extract_mk(filepath, prefix):
	"""
	Constructs a dictionary consiting of lists of the source
	do-file(s) and the prerequisites and targets. The argName
	key contains the Stata macro holding the argument passed.
	"""
	mk = {	"#DOFILE": [filepath],
			"#PREREQ": [],
			"#TARGET": [],
			"argName": None,
		}
	with open(filepath, 'r') as fobj:
		for line in fobj:
			if line.startswith("args"):
				mk["argName"] = line.split(" ")[1].strip()
				mk["argName"] = "`" + mk["argName"] + "'"
			else:
				for key in mk.keys():
					match = parse_line(key, line, mk["argName"])
					if match is not None:
						mk[key].append(match)
						break

	for vlist in [mk["#PREREQ"], mk["#TARGET"]]:
		vlist = adjust_paths(prefix, vlist)

	return mk
	
def write_mk(mk, paths):
	"""
	Writes a .mk file to be included by a makefile.
	"""
	do = paths['relative']
	if mk["argName"] is not None:
		do += " $*"

	logname = paths['basename'].replace(".do", ".log")
	loginitial = os.path.join(paths['module'], logname)
	logfinal = os.path.join(paths['subdir'], "logs", logname)

	doline = "dofiles = " + " \\\n\t".join(mk["#DOFILE"])
	prereqline = "prereqs = " + " \\\n\t".join(mk["#PREREQ"])
	targetline = "targets = " + " \\\n\t".join(mk["#TARGET"])

	mkname = paths['full'].replace(".do", ".mk")

	body = "\n".join([doline, prereqline, targetline])
	with open(mkname, 'w') as fobj:
		fobj.write(body + '\n')
		fobj.write("$(targets) : $(dofiles) $(prereqs)\n")
		fobj.write(f"\tcd {paths['module']} && $(STATA) {do}\n")
		fobj.write(f"\t@-mv {loginitial} {logfinal}")

filepath = sys.argv[1]

paths = parse_path(filepath)
mk = extract_mk(filepath, paths['module'])
write_mk(mk, paths)