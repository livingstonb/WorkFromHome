
// .datasets = .statalist.new
// .descriptions = .statalist.new
file close
foreach dataset of local datasets {
	file write "FILE : `dataset'" _n

	describe "`dataset'", short
	file write "DESCRIPTION : `r(datalabel)'" _n _n
	
// 	.datasets.append "`dataset'"
// 	.descriptions.append "`r(datalabel)'"
}

file open using "misc/files.txt", write





