PAPERNAME=paper

all:
	pdflatex -shell-escape $(PAPERNAME)
	bibtex $(PAPERNAME)
	pdflatex $(PAPERNAME)
	pdflatex $(PAPERNAME)

spell:
	find . -maxdepth 2 -iname '*.tex' -not -name '${PAPERNAME}.tex' -exec cat {} + | aspell -a --add-extra-dicts=./dict --add-filter=tex | tail -n+2 | grep -v \* | cut -d\  -f2 | sort | uniq | cat -s

# These are for diffing between major paper versions. First, checkout
# the 'old' version, run latexpand paper.tex > old-paper.tex, then
# return to HEAD and run make diff
new-$(PAPERNAME).tex: $(PAPERNAME).tex
	latexpand $(PAPERNAME).tex > new-$(PAPERNAME).tex

# latexdiff is odd sometimes, and can require explicilty exempting
# some things from diff highlighting, add those here
diff-$(PAPERNAME).tex: old-$(PAPERNAME).tex new-$(PAPERNAME).tex
	latexdiff --config="PICTUREENV=(?:picture|DIFnomarkup|table|CCSXML|comment)[\w\d*@]*" --exclude-textcmd="subsection,title,author" old-$(PAPERNAME).tex new-$(PAPERNAME).tex > diff-$(PAPERNAME).tex

diff: diff-$(PAPERNAME).tex
	pdflatex -shell-escape diff-$(PAPERNAME)
	bibtex diff-$(PAPERNAME)
	pdflatex diff-$(PAPERNAME)
	pdflatex diff-$(PAPERNAME)

embed-fonts: ${PAPERNAME}.pdf
	gs -q -dNOPAUSE -dBATCH -dPDFSETTINGS=/prepress -sDEVICE=pdfwrite -sOutputFile=${PAPERNAME}_embedded.pdf ${PAPERNAME}.pdf

greyscale: ${PAPERNAME}.pdf
	gs -sOutputFile=${PAPERNAME}_grey.pdf -sDEVICE=pdfwrite -sColorConversionStrategy=Gray -dProcessColorModel=/DeviceGray -dCompatibiltyLevel=1.4 -dNOPAUSE -dBATCH ${PAPERNAME}.pdf

clean:
	rm *.ps $(PAPERNAME).pdf *.dvi *.aux *.log *.blg *.bbl *.ilg *.idx *.out *.in
