import os
import subprocess

def unzip_all(dirpath):
	files = os.listdir(dirpath)
	# print(files)
	files = filter(
		lambda x: x.endswith('.zip'), files)

	for file in files:
		outdir = file.replace('.zip', '')
		outdir = outdir.replace('zips', 'unzipped')
		outdir = os.path.join(dirpath, outdir)
		strcmd = ['unzip', '-d', outdir]
		# print(strcmd)
		subprocess.run(['unzip', '-d', outdir])


zips = 'build/input/raw_yearly/zips'
unzip_all(zips)