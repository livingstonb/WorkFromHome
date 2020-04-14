import os
# import misc.parse_instructions

def write_rule(targets, prereqs, source):
	base = source.split('/')[0]
	prereqs = [source] + prereqs
	do = os.path.join(*source.split('/')[1:])

	line1 = 'targets = ' + ' \\\n\t'.join(targets) 
	line2 = 'prereqs = ' + ' \\\n\t'.join(prereqs)
	lines_out = '\n'.join([line1, line2])
	statement = '$(targets) : $(prereqs)'
	recipe = f'\tcd {base} && $(STATA) {do}'
	
	expr = '\n'.join([lines_out, statement, recipe])
	return expr

def write_mk(targets, prereqs, source):
	mkname = source.replace('.do', '.mk')

	for i in range(len(targets)):
		print(write_rule(targets[i], prereqs[i], source))
		print('---\n---')

def read_oes():
	source = 'OES/build/code/read_oes.do'
	build = os.path.join('OES', 'build', 'input', 'raw')

	prereqs = [	'oes00in3/nat2d_sic_2000_dl.xls',
				'oes01in3/nat2d_sic_2001.xls',
				'oes02in4/nat4d_2002_dl.xls',
				'oesm03in4/nat3d_may2003_dl.xls',
				'oesm04in4/natsector_may2004_dl.xls',
				'oesm05in4/natsector_may2005_dl.xls',
				'oesm06in4/natsector_may2006_dl.xls',
				'oesm07in4/natsector_may2007_dl.xls',
				'oesm08in4/natsector_M2008_dl.xls',
				'oesm09in4/natsector_M2009_dl.xls',
				'oesm10in4/natsector_M2010_dl.xls',
				'oesm11in4/natsector_M2011_dl.xls',
				'oesm12in4/oesm12in4/natsector_M2012_dl.xls',
				'oesm13in4/oesm13in4/natsector_M2013_dl.xls',
				'oesm14in4/oesm14in4/natsector_M2014_dl.xlsx',
				'oesm15in4/oesm15in4/natsector_M2015_dl.xlsx',
				'oesm16in4/oesm16in4/natsector_M2016_dl.xlsx',
				'oesm17in4/oesm17in4/natsector_M2017_dl.xlsx',
				'oesm18in4/oesm18in4/natsector_M2018_dl.xlsx',
				'oesm19in4/oesm19in4/natsector_M2019_dl.xlsx',
	]
	prereqs = [os.path.join(build, x) for x in prereqs]

	for file in prereqs:
		if not os.path.isfile(file):
			print(f'File not found:')
			print(f'\t{file}')
	prereqs = [[x] for x in prereqs]

	digits = [2] * 20
	digits[2] = 4
	digits[3] = 3
	years = list(range(2000, 2020))

	base = os.path.join('OES', 'build', 'output')
	targets = []
	for i in range(20):
		targets.append(
				[os.path.join(base, f'oes{digits[i]}d{years[i]}.dta')]
			)

	write_mk(targets, prereqs, source)

	# paths = parse_instructions.parse_path(target)
	# for target in targets:
	# 	paths = parse_instructions.parse_path(target)

read_oes()