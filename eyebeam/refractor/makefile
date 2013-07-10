SRC = $(shell find web/src -name "*.coffee")

web/compiled: $(SRC)
	node web/compile.js
	rm -r refractor.ad/AdUnit/*
	cp -r web/* refractor.ad/AdUnit
	zip -r refractor.ad.zip refractor.ad
	touch web/compiled