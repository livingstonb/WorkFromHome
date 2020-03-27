import pandas as pd
import os

def read_codes(fpath):
	groups = dict()
	codes = []
	with open(fpath, 'r') as fobj:
		icat = 0
		for line in fobj:
			fcode = line[0:7]
			nid = int(fcode[3:])
			print(nid)
			if nid == 0:
				pass
			elif (nid % 1000) == 0:
				last_cat = line[9:-1]
				last_code = fcode
				groups[fcode] = last_cat

				icat += 1
				code = {
					'catid': icat,
					'catcode': last_code,
					'fcode': fcode,
					'category': last_cat,
					'detailed': line[9:],
				}
				codes.append(code)
			else:
				code = {
					'catid': icat,
					'catcode': last_code,
					'fcode': fcode,
					'category': last_cat,
					'detailed': line[9:],
				}
				codes.append(code)
	
	codes = pd.DataFrame(codes)
	return codes, groups

def create_paths(maindir, year):
	paths = dict()
	paths['maindir'] = maindir
	paths['yeardir'] = os.path.join(maindir, "occ_codes_" + year)

	txtpath = "input/occ_soc_" + year + ".txt"
	paths['txt'] = os.path.join(paths['yeardir'], txtpath)

	paths['temp'] = os.path.join(paths['yeardir'], "temp")
	paths['csv'] = os.path.join(paths['temp'], "soc_3digit_map.csv")

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

maindir = "/media/hdd/GitHub/WorkFromHome/other"
year = "2010"
paths = create_paths(maindir, year)
codes, groups = read_codes(paths['txt'])
codes.to_csv(paths['csv'])