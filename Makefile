PAPERNAME=paper

# Set wherever you put figs (images, pdfs, etc)
FIG_DIRS := fig/ figs/ img/ figures/

# Look for TEX files, drop new- and old- and diff- prefixed versions of the main file.
TEX_SOURCES := $(shell find . -maxdepth 2 -iname '*.tex' -not -name '*-${PAPERNAME}.tex')

# Look for images
IMG_SOURCES := $(shell find $(FIG_DIRS) 2&>/dev/null)

all: $(PAPERNAME).pdf

# Rebuild for changes to tex and images
$(PAPERNAME).pdf: $(TEX_SOURCES) $(IMG_SOURCES)
	pdflatex -shell-escape $(PAPERNAME)
	bibtex $(PAPERNAME)
	pdflatex -shell-escape $(PAPERNAME)
	pdflatex -shell-escape $(PAPERNAME)

spell:
	find . -maxdepth 2 -iname '*.tex' -not -name '${PAPERNAME}.tex' -exec cat {} + | aspell -a --add-extra-dicts=./dict --add-filter=tex | tail -n+2 | grep -v \* | cut -d\  -f2 | sort | uniq | cat -s

# These are for diffing between major paper versions. First, checkout
# the 'old' version, run make old, then return to HEAD and run make
# diff
new-$(PAPERNAME).tex: $(TEX_SOURCES) $(IMG_SOURCES)
	latexpand $(PAPERNAME).tex > new-$(PAPERNAME).tex

# latexdiff is odd sometimes, and can require explicilty exempting
# some things from diff highlighting, add those here
diff-$(PAPERNAME).tex: old-$(PAPERNAME).tex new-$(PAPERNAME).tex
	latexdiff --config="PICTUREENV=(?:picture|DIFnomarkup|table|CCSXML|comment)[\w\d*@]*" --exclude-textcmd="subsection,title,author" old-$(PAPERNAME).tex new-$(PAPERNAME).tex > diff-$(PAPERNAME).tex

diff: diff-$(PAPERNAME).tex
	pdflatex -shell-escape diff-$(PAPERNAME)
	bibtex diff-$(PAPERNAME)
	pdflatex -shell-escape diff-$(PAPERNAME)
	pdflatex -shell-escape diff-$(PAPERNAME)

# Utility for making the old thing, you still need to checkout the right thing
old:
	latexpand $(PAPERNAME).tex > old-$(PAPERNAME).tex

embed-fonts: ${PAPERNAME}.pdf
	gs -q -dNOPAUSE -dBATCH -dPDFSETTINGS=/prepress -sDEVICE=pdfwrite -sOutputFile=${PAPERNAME}_embedded.pdf ${PAPERNAME}.pdf

greyscale: ${PAPERNAME}.pdf
	gs -sOutputFile=${PAPERNAME}_grey.pdf -sDEVICE=pdfwrite -sColorConversionStrategy=Gray -dProcessColorModel=/DeviceGray -dCompatibiltyLevel=1.4 -dNOPAUSE -dBATCH ${PAPERNAME}.pdf

clean:
	rm *.ps $(PAPERNAME).pdf *.dvi *.aux *.log *.blg *.bbl *.ilg *.idx *.out *.in
