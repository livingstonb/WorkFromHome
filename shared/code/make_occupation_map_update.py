import pandas as pd
import os
import pdb

def read_codes(fpath):
	groups = dict()
	codes = []

	itwodigit = 0
	ithreedigit = 0
	twodigit_last = -1
	threedigit_last = -1

	with open(fpath, 'r') as fobj:
		
		for line in fobj:
			soccode = line[0:7]
			soccint = int(soccode.replace("-", ""))
			twodigit = soccint // 10000
			threedigit = soccint // 1000

			makeNewEntry = True
			if (twodigit > twodigit_last):
				# New 2-digit category
				label2digit = line[9:-1]
				itwodigit += 1
				makeNewEntry = False
			elif (threedigit > threedigit_last):
				# New 3-digit category
				label3digit = line[9:-1]
				ithreedigit += 1

			if makeNewEntry:
				# Continue in current 3-digit category
				entry = {
					'soc': soccode,
					'occ2labels': label2digit,
					'occ2id': itwodigit,
					'occ3labels': label3digit,
					'occ3id': ithreedigit,
				}
				codes.append(entry)

			twodigit_last = twodigit
			threedigit_last = threedigit
	
	codes = pd.DataFrame(codes)
	return codes

def create_paths(maindir, year):
	paths = dict()
	paths['maindir'] = maindir
	paths['yeardir'] = os.path.join(maindir, "occ" + year)

	txtpath = "input/occ_soc_" + year + ".txt"
	paths['txt'] = os.path.join(paths['yeardir'], txtpath)

	paths['temp'] = os.path.join(paths['yeardir'], "temp")
	paths['csv'] = os.path.join(paths['temp'], "soc" + year + ".csv")

	if not os.path.exists(paths['temp']):
		os.mkdir(paths['temp'])

	return paths

# maindir = "/media/hdd/GitHub/WorkFromHome/other/occ_codes_2018"
# fpath = os.path.join(maindir, "input/occ_soc_2018.txt")

# codes, groups = read_codes(fpath)

# csvdir = os.path.join(maindir, "temp")
# csvpath = os.path.join(csvdir, "soc_3digit_map.csv")

# if not os.path.exists(csvdir):
# 	os.mkdir(csvdir)

# codes.to_csv(csvpath)

# for key, value in codes.items():
# 	print(f'{key}: {value}')

maindir = "/media/hdd/GitHub/WorkFromHome/shared"
year = "2018"
paths = create_paths(maindir, year)
codes = read_codes(paths['txt'])
codes.to_csv(paths['csv'])
print(codes)