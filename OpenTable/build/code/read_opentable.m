

clear
addpath('build/code')

filepath = 'build/input/state_of_industry.csv';
data = readcell(filepath);
data = reshape_long(data)