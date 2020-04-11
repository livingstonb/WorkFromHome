import os
import sys

def get_sources(args):
	sources = []
	for dirpath in args['dirs']:
		for file in os.listdir(dirpath):
			if file.endswith(args['suffix']):
				sources.append(os.path.join(dirpath, file))

	post = -len(args['suffix'])
	basenames = [file[:post] for file in sources]

	return (sources, basenames)

def find_needed_mks(basenames):
	mks = []
	for name in basenames:
		if not os.path.isfile(name + ".mk"):
			mks.append(name + ".mk-auto")

	return mks

def src_line(sources):
	return " ".join(["SRC ="] + sources)

def inc_line(mks):
	return " ".join(["INCLUDES ="] + mks)

def write_mk(args, sources, mks):
	with open(args['outpath'], 'w') as fobj:
		fobj.write(src_line(sources))
		fobj.write('\n')
		fobj.write(inc_line(mks))

def parse(cmdargs):
	args = dict()

	args['suffix'] = cmdargs[1]
	args['outpath'] = cmdargs[2]
	args['dirs'] = cmdargs[3:]

	return args

def main(cmdargs):
	args = parse(cmdargs)
	sources, basenames = get_sources(args)
	mks = find_needed_mks(basenames)
	write_mk(args, sources, mks)

main(sys.argv)