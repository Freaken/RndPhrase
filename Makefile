all: conkeror firefox

BUILD_VERSION=0
BUILD_PATCH=8
BUILD_SUB=0

VERSION = "$(BUILD_VERSION).$(BUILD_PATCH).$(BUILD_SUB)"


NAME="RndPhrase"
DESC="Auto-generated secure passwords."
CREATOR="Johan Brinch"
HOMEPAGE="http://github.com/brinchj/RndPhrase"


CONKEROR_BUILD=build/conkeror
FIREFOX_BUILD=build/firefox
CHROME_BUILD=build/chrome
WWW_BUILD=build/www

CHROME=google-chrome
FIREFOX=firefox


CPP=gcc -c -C -P -E -xc -I. \
	-D'NAME=${NAME}' -D'DESC=${DESC}' -D'CREATOR=${CREATOR}' \
	-D'HOMEPAGE=${HOMEPAGE}' -D'VERSION=${VERSION}'
LIB=Makefile lib/cubehash.js lib/rndphrase.js


conkeror_js.js: ${LIB} conkeror/page-modes/rndphrase.js
	${CPP} conkeror/page-modes/rndphrase.js -o conkeror_js.js

conkeror: conkeror_js.js
	mkdir -p ${CONKEROR_BUILD}/page-modes && \
  mv conkeror_js.js ${CONKEROR_BUILD}/page-modes/rndphrase.js && \
	echo ">> Conkeror page-mode: ${CONKEROR_BUILD}/page-modes/rndphrase.js"


firefox_meta: ${LIB} firefox/install.rdf
	${CPP} firefox/install.rdf -o firefox_meta

firefox_js.js: ${LIB} firefox/chrome/content/rndphrase/rndphrase.xul
	${CPP} firefox/chrome/content/rndphrase/rndphrase.xul -o firefox_js.js

firefox: firefox_meta firefox_js.js
	mkdir -p ${FIREFOX_BUILD}/_src && \
	cp -r firefox/* ${FIREFOX_BUILD}/_src && \
	mv firefox_meta ${FIREFOX_BUILD}/_src/install.rdf && \
	mv firefox_js.js ${FIREFOX_BUILD}/_src/chrome/content/rndphrase/rndphrase.xul && \
	cd ${FIREFOX_BUILD}/_src && \
	./pack.sh && \
	mv rndphrase.xpi ../ && \
	cd .. && rm -rf _src && \
	echo ">> Firefox addon: ${FIREFOX_BUILD}/rndphrase.xpi" && \
	echo ">> Install by running 'make firefox_install'"

firefox_install: firefox
	${FIREFOX} build/firefox/rndphrase.xpi


chrome_meta: ${LIB} chrome/manifest.json
	${CPP} chrome/manifest.json -o chrome_meta

chrome_js.js: ${LIB} chrome/overlay.js
	${CPP} chrome/overlay.js -o chrome_js.js

chrome: chrome_meta chrome_js.js
	if ( pgrep chrome ); then echo "!! Google Chrome is running."; exit -1; fi && \
	mkdir -p ${CHROME_BUILD}/_src && \
	cp -r chrome/* ${CHROME_BUILD}/_src && \
	mv chrome_meta ${CHROME_BUILD}/_src/manifest.json && \
	mv chrome_js.js ${CHROME_BUILD}/_src/overlay.js && \
  ${CHROME} --pack-extension=${CHROME_BUILD}/_src --pack-extension-key=chrome/unofficial_key.pem && \
  mv ${CHROME_BUILD}/_src.crx ${CHROME_BUILD}/rndphrase.crx && \
  rm -rf ${CHROME_BUILD}/_src && \
	echo ">> Chrome addon: build/chrome/rndphrase.crm" && \
	echo ">> Install by running 'make chrome_install'"

chrome_install: chrome
	${CHROME} build/chrome/rndphrase.crx


www_html.html: ${LIB} www/index.html
	${CPP} www/index.html -o www_html.html

www: www_html.html
	mkdir -p ${WWW_BUILD} && \
	cp -r www/* ${WWW_BUILD} && \
	mv www_html.html ${WWW_BUILD}/index.html && \
	echo ">> Html version: ${WWW_BUILD}/index.html"
