import sys
import re

def parse():
	currdir = 'WorkFromHome'
	pat = r'cd\s+?(\w+).*?do\s+?(.*\.do)?'
	commands = []
	dirs_seen = set()
	for line in sys.stdin:
		try:
			reobj = re.search(pat, line)
			if reobj is None:
				continue
			else:
				matches = reobj.groups()

			if len(matches) >= 2 :
				basedir = matches[0]
				dofile = matches[1]

				if (currdir != 'WorkFromHome') and (currdir != basedir):
					commands.append(f'\ncd "../{basedir}"')
				elif currdir != basedir:
					commands.append(f'\ncd "{basedir}"')
				currdir = basedir

				if currdir not in dirs_seen:
					objdir = dofile.split('/')[0]
					commands.append(f'mkdir -p {objdir}/output')
					commands.append(f'mkdir -p {objdir}/temp')
					dirs_seen.add(currdir)

				commands.append(f'do "{dofile}"')

		except Exception as e:
			print(e)

	print('\n'.join(commands))


if __name__ == '__main__':
	parse()