MDS = $(shell find . -name "*.md")
MDSCONVERTED = $(MDS:.md=.html)

all: $(MDSCONVERTED)

$(MDSCONVERTED): %.html: %.md
	pandoc -f markdown_strict -t html -S --template=./template.html -o $@ $<