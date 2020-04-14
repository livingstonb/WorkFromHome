import sys
import re

def parse():
	currdir = 'WorkFromHome'
	pat = r'cd\s+?(\w+?)\s+(.*?\s*+.)?(.*\.do)?'
	pat = r'cd\s+?(\w+).*?do\s+?(.*\.do)?'
	commands = []
	for line in sys.stdin:
		try:
			matches = re.search(pat, line).groups()
			if len(matches) >= 2 :
				basedir = matches[0]
				dofile = matches[1]

				if (currdir != 'WorkFromHome') and (currdir != basedir):
					commands.append(f'\ncd "../{basedir}"')
				elif currdir != basedir:
					commands.append(f'\ncd "{basedir}"')
				currdir = basedir

				commands.append(f'do "{dofile}"')
		except Exception as e:
			pass

	print('\n'.join(commands))


if __name__ == '__main__':
	parse()