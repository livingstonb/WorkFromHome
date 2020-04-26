import pandas as pd
import re

def strip_abbrev(state):
	pattern = r'\s\([A-Z]+\)'
	abbrev = re.findall(pattern, state)[0]
	return state.replace(abbrev, '')

def clean(filepath):
	df = pd.read_csv(filepath, delimiter=';')
	df['State'] = df['State'].apply(strip_abbrev)
	df.rename(
		columns={
			'State': 'state',
			'Date of Stay at home': 'stay_at_home',
			'Date first business closure': 'business_closure',
			'Date of SOE': 'state_of_emergency',
			},
		inplace=True
		)

	keep = [
		'state',
		'stay_at_home',
		'business_closure',
		'state_of_emergency',
		]
	df = df[keep]
	df['state_of_emergency'][df['state'] == 'Oregon'] = 'March 8'

	for col in ['stay_at_home', 'business_closure', 'state_of_emergency']:
		df[col] = df[col] + ' 2020'

	return df

filepath = 'build/input/coronavirus_state_tracking.csv'
df = clean(filepath)

outpath = 'build/temp/coronavirus_state_tracking.csv'
df.to_csv(outpath, header=True)