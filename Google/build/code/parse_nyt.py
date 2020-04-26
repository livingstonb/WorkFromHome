"""
Parses html of a NYT article for dates of stay-at-home orders by state.

Source:
	Sarah Mervosh, Denise Lu, and Vanessa Swales. See Which States and Cities
	Have Told Residents to Stay at Home. The New York Times. Accessed online,
	4/26/20.
"""

import os
import re
import pandas as pd

def parse_html(filepath, print_matches=False):
	statepattern = r'<h3>([a-zA-Z\s]+)?<'
	datepattern = r'effective\s(.*)</span></p>$'

	found = dict()

	lookFor = 'State'
	with open(filepath, 'r') as fobj:
		for line in fobj:
			cline = line.lstrip()
			if lookFor == 'State':
				if cline.startswith(r'<h3>'):
					state = re.findall(
						statepattern, cline)[0].strip()
					lookFor = 'Date'
			elif lookFor == 'Date':
				if 'effective' in cline:
					date = re.findall(
						datepattern, cline)[0].strip()

					if print_matches:
						print(f'{state} --> {date}')

					found[state] = date
					lookFor = 'State'

	return found

def clean(dict_in):
	pattern = r':[0-9]+'
	dict_out = dict()
	for key, value in dict_in.items():
		dict_out[key] = value.replace(
			'p.m.', 'PM').replace('a.m.', 'AM')

		if ' at ' not in value:
			dict_out[key] = dict_out[key] + ' at 12 PM'

		dict_out[key] = dict_out[key].replace('at ', '')

		try:
			match = re.findall(
				pattern, dict_out[key])[0]
			dict_out[key] = dict_out[key].replace(match, '')
		except:
			pass

	dict_out['Ohio'] = dict_out['Ohio'].replace('pm.', 'PM')

	return dict_out

def write_csv(dict_in, outpath):
	ser = pd.Series(dict_in)
	print(ser)
	ser.to_csv(outpath, header=['date'], index_label=['state'])

if __name__ == '__main__':
	filepath = 'build/input/NYT_stay_at_home.html'
	found = parse_html(filepath)
	cleaned = clean(found)

	outpath = 'build/temp/stay_at_home.csv'
	write_csv(cleaned, outpath)