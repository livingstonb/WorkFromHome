import os
import re
import sys

class StataParser:
	def __init__(self, filepath):
		self.parse_path(filepath)
		self.parse_do()
		self.check()

		horzline = ''.join(['-'] * 100)
		self.header = 	(
						f'# {horzline}\n'
						f'# This is an automatically generated file\n'
						f'# created by make_tools.py.\n'
						f'#\n'
						f'# Do-file source:\n'
						f'#\t{self.full}\n'
						f'# {horzline}\n\n'
					)

	def parse_path(self, fpath):
		"""
		Extracts different variables associated with filepath.
		"""
		paths = dict()
		dirnames = fpath.split("/")
		self.module = dirnames[0]
		self.subdir = os.path.join(*dirnames[:2])
		self.objdir = os.path.join(*dirnames[:3])
		self.basename = os.path.basename(fpath)
		self.relative = os.path.join(*dirnames[1:])
		self.full = fpath
		self.mkpath = self.full.replace('.do', '.mk')

		logname = self.basename.replace('.do', '.log')
		self.loginitial = os.path.join(self.module, logname)
		self.logfinal = os.path.join(self.subdir, 'logs', logname)

	def parse_do(self):
		mk = {	"#PREREQ": [],
				"#TARGET": [],
				"argName": None,
		}

		with open(self.full, 'r') as fobj:
			for line in fobj:
				if line.startswith("args"):
					word = line.split(" ")[1].strip()
					mk["argName"] = f"`{word}'"
				else:
					for key in mk.keys():
						match = parse_line(key, line, mk["argName"])
						if match is not None:
							mk[key].append(match)
							break
		
		self.mk = {	'prereqs': adjust_paths(
						self.module, mk['#PREREQ']),
					'targets': adjust_paths(
						self.module, mk['#TARGET']),
					'argName': mk['argName'],
			}
		self.mk['prereqs'].insert(0, self.full)

	def check(self):
		prefix = f'Source file {self.full} warning:\n'
		if len(self.mk['targets']) == 0:
			print(prefix, f'\tNo targets found')

	def write_mk(self):
		"""
		Writes a .mk file to be included by a makefile.
		"""
		do = self.relative
		if self.mk["argName"] is not None:
			do += " $*"

		newdirnames = ['temp', 'output', 'logs']
		newdirs = [f'{self.subdir}/{x}' for x in newdirnames]
		newdirlines = '\n'.join([f'\t@mkdir -p {x}' for x in newdirs])

		prereqlines = 'prereqs := ' + ' \\\n\t'.join(self.mk['prereqs'])
		targetlines = 'targets := ' + ' \\\n\t'.join(self.mk["targets"])
		with open(self.mkpath, 'w') as fobj:
			fobj.write(self.header)
			fobj.write(prereqlines)
			fobj.write('\n')
			fobj.write(targetlines)
			fobj.write("\n.PRECIOUS : $(targets)\n")
			fobj.write("$(targets) : $(prereqs)\n")
			fobj.write(newdirlines)
			fobj.write('\n')
			fobj.write(f"\tcd {self.module} && $(STATA) {do}\n")
			fobj.write(f"\t@-mv {self.loginitial} {self.logfinal}")

	def write_txt(self):
		if len(self.mk['prereqs']) > 0:
			prereqs = '\n'.join(
				*[f'#PREREQ = "{x}"' for x in self.mk['prereqs']])
			txt += prereqs

		if len(self.mk['targets']) > 0:
			targets = '\n'.join(
				*[f'#TARGET = "{x}"' for x in self.mk['targets']])
			txt += prereqs

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

if __name__ == '__main__':
	stata_parser = StataParser(sys.argv[1])
	stata_parser.write_mk()