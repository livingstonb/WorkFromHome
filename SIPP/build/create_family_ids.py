import pandas as pd
import numpy as np
import os

def read_df(outdir, fname):
	inpath = os.path.join(outdir, fname)
	df = pd.read_csv(inpath)

	return df

def printvariables(df):
	for col in df.columns:
		print(col)

def compute_family_ids(df):
	df.sort_values(by=["monthcode", "personid"], inplace=True)

	families = dict()
	mslice = df[df["monthcode"] == 1]
	family_ids = pd.unique(mslice["familyid"])

	for familyid in family_ids:
		fslice = mslice[mslice["familyid"] == familyid]

		newfamily = pd.unique(fslice["personid"])
		families[familyid] = newfamily

	for month in range(2, 13):
		mslice = df[df["monthcode"] == month]

		for famid, personids in families.items():
			person0 = personids[0]
			p0slice = mslice.loc[mslice["personid"] == person0,:]
			residence0 = p0slice["eresidenceid"]
			rfamnum0 = p0slice["rfamnum"]
			for person in personids[1:]:
				pslice = mslice.loc[mslice["personid"] == person0,:]



maindir = "/media/hdd/GitHub/WorkFromHome/SIPP"
outdir = os.path.join(maindir, "output")
fname = "identifiers.csv"

df = read_df(outdir, fname)
printvariables(df)

compute_family_ids(df)