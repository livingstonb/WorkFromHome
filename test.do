
args onearg

clear

tokenize "`onearg'"
while "`1'" != "" {
	di "`1'"
	macro shift
}
