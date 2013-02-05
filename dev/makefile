SRC = $(shell find components js -name "*.js" -or -name "*.css")

COFFEESCRIPTS = $(shell find . -name "*.coffee")
COFFEESCRIPTSCONVERTED = $(COFFEESCRIPTS:.coffee=.js)

COMPONENTJSONS = $(shell find . -name "component.json")

MDS = $(shell find ./book -name "*.md")
MDSCONVERTED = $(MDS:.md=.html)

build: components $(COFFEESCRIPTSCONVERTED) $(SRC) $(MDSCONVERTED)
	component build
	touch build

components: $(COMPONENTJSONS)
	component install
	touch components

$(COFFEESCRIPTSCONVERTED): %.js: %.coffee
	coffee -c $<

$(MDSCONVERTED): %.html: %.md
	pandoc -t html -S --template=./book/template.html -o $@ $<