SRC = $(shell find components -name "*.js")
COFFEESCRIPTS = $(shell find . -name "*.coffee")
COFFEESCRIPTSCONVERTED = $(COFFEESCRIPTS:.coffee=.js)

COMPONENTJSONS = $(shell find . -name "component.json")

build: components $(COFFEESCRIPTSCONVERTED) $(SRC)
	component build
	touch build

components: $(COMPONENTJSONS)
	component install
	touch components

$(COFFEESCRIPTSCONVERTED): %.js: %.coffee
	coffee -c $<