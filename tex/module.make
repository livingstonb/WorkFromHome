texloc = tex/data_methods/data_methods
texexts = .aux .bbl .blg .log .out .pdf
texfiles := $(addprefix $(texloc), texexts)
tex :
	rm -f $(texfiles)
	cd tex/data_methods && pdflatex data_methods
	cd tex/data_methods && bibtex data_methods
	cd tex/data_methods && pdflatex data_methods
	cd tex/data_methods && pdflatex data_methods