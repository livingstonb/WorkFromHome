

.PHONY : build

build : build/temp/coronavirus_state_tracking.csv \
	build/temp/stay_at_home.csv \
	build/output/state_level_data.mat \
	build/output/state_time_series.mat

build/temp/coronavirus_state_tracking.csv : build/code/clean_state_tracking.py
	mkdir -p build/temp
	python -u $<

build/temp/stay_at_home.csv : build/code/parse_nyt.py
	mkdir -p build/temp
	python -u $<

build/output/state_level_data.mat : build/code/state_characteristics.m
	mkdir -p build/output
	matlab -batch "run('build/code/state_characteristics.m')"

build/output/state_time_series.mat : build/code/state_characteristics.m
	mkdir -p build/output
	matlab -batch "run('build/code/merge.m')"

# # Convert xlsx to tex table
# Google/stats/output/mobility_changes.tex : Google/stats/output/mobility_changes.xlsx
# 	python misc/xlsx_to_latex.py $<

# # Compile pdf
# mobility_tex_src := Google/stats/tex/estimates.tex
# mobility_tex_objs := reg_table.tex mobility_changes.tex
# mobility_tex_objs := $(addprefix Google/stats/output/, $(mobility_tex_objs))
# Google/stats/tex/estimates.pdf : $(mobility_tex_objs) $(mobility_tex_src)
# 	@cd Google/stats/tex && pdflatex estimates