import pandas as pd
import os

def read(filepath):
	df = pd.read_csv(filepath)



dirpath = 'build/input/csse_covid_19_daily_reports_us'
date = '04-12-2020'