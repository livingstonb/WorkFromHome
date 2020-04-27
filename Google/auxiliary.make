# Additional make recipes for Google module

google_merged = Google/build/output/state_time_series.mat

.PHONY : mobility_figures mobility_stats

subdir_names = temp logs output

# python code
state_tracking_data = Google/build/temp/coronavirus_state_tracking.csv
state_tracking_log = build/logs/clean_state_tracking.log
state_tracking_src = Google/build/code/clean_state_tracking.py
state_tracking_objs = Google/build/input/coronavirus_state_tracking.csv
$(state_tracking_data) : $(state_tracking_src) $(state_tracking_objs)
	@cd Google/build && mkdir -p $(subdir_names)
	cd Google && python -u build/code/clean_state_tracking.py > $(state_tracking_log)

stay_at_home_data = Google/build/temp/stay_at_home.csv
stay_at_home_log = build/logs/stay_at_home.log
stay_at_home_src = Google/build/code/parse_nyt.py
stay_at_home_objs = Google/build/input/NYT_stay_at_home.html
$(stay_at_home_data) : $(stay_at_home_src) $(stay_at_home_objs)
	@cd Google/build && mkdir -p $(subdir_names)
	cd Google && python -u build/code/parse_nyt.py > $(stay_at_home_log)

# MATLAB code
states_data = Google/build/output/state_level_data.mat
states_src := Google/build/code/state_characteristics.m
states_objs := temp/stay_at_home.csv input/school_closures.csv
states_objs += input/state_data.xlsx input/dine_in_bans.csv
states_objs += temp/coronavirus_state_tracking.csv
states_objs := $(addprefix Google/build/, $(states_objs))
states_cmd := -logfile build/logs/state_characteristics.log
states_cmd += -batch "run('build/code/state_characteristics.m')"
$(states_data) : $(states_src) $(states_objs)
	@cd Google/build && mkdir -p $(subdir_names)
	cd Google && matlab $(states_cmd)

merge_src := Google/build/code/merge.m
merge_objs := Google/build/input/cleaned_mobility_report.csv
merge_objs += Google/build/output/state_level_data.mat
merge_cmd := -logfile build/logs/merge.log
merge_cmd += -batch "run('build/code/merge.m')"
merge_target2 := Google/build/output/state_time_series.csv
$(google_merged) $(merge_target2): $(merge_src) $(merge_objs)
	@cd Google/build && mkdir -p $(subdir_names)
	cd Google && matlab $(merge_cmd)

figures_src := Google/stats/code/figures.m
figures_cmd := -logfile stats/logs/figures.log
figures_cmd += -batch "run('stats/code/figures')"
mobility_figures : $(figures_src) $(google_merged)
	@cd Google/stats && mkdir -p $(subdir_names)
	cd Google && matlab -noFigureWindows $(figures_cmd)

mobility_stats : Google/stats/tex/estimates.pdf

# Convert xlsx to tex table
Google/stats/output/mobility_changes.tex : Google/stats/output/mobility_changes.xlsx
	python misc/xlsx_to_latex.py $<

# Compile pdf
mobility_tex_src := Google/stats/tex/estimates.tex
mobility_tex_objs := reg_table.tex mobility_changes.tex
mobility_tex_objs := $(addprefix Google/stats/output/, $(mobility_tex_objs))
Google/stats/tex/estimates.pdf : $(mobility_tex_objs) $(mobility_tex_src)
	@cd Google/stats/tex && pdflatex estimates