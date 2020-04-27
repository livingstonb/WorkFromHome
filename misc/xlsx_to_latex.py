import sys
import os
import pandas as pd

def xlsx_to_latex(filepath):
	df = pd.read_excel(filepath, index_col=0)
	tex = df.to_latex(float_format="%.1f")

	outpath = filepath.replace('.xlsx', '.tex')
	with open(outpath, 'w') as fobj:
		fobj.write(tex)

if __name__ == '__main__':
	xlsx_to_latex(sys.argv[1])