# Build the pytz libraries
#

MAKE=make
PYTHON24=python2.4
PYTHON25=python2.5
PYTHON=${PYTHON24}
OLSON=./elsie.nci.nih.gov
TESTARGS=-vv
TARGET=
#TARGET=Europe/Amsterdam Europe/Moscow W-SU Etc/GMT+2 Atlantic/South_Georgia Europe/Warsaw Europe/Vilnius
#Mideast/Riyadh87
STYLESHEET=/usr/share/python-docutils/stylesheets/default.css

all: dist

# skip test_zdump, since it fails on AMD64, and takes a long time on i386
check: test_tzinfo test_docs

dist: build/dist/locales/pytz.pot .stamp-dist
.stamp-dist: .stamp-tzinfo
	cd build/dist && mkdir -p ../tarballs && \
	${PYTHON} setup.py sdist --dist-dir ../tarballs \
	    --formats=bztar,gztar,zip && \
	${PYTHON24} setup.py bdist_egg --dist-dir=../tarballs && \
	${PYTHON25} setup.py bdist_egg --dist-dir=../tarballs
	touch $@

upload: build/dist/locales/pytz.pot .stamp-upload
.stamp-upload: .stamp-tzinfo
	cd build/dist && \
	${PYTHON} setup.py register sdist \
	    --formats=bztar,gztar,zip --dist-dir=../tarballs \
	    upload --sign && \
	${PYTHON24} setup.py register bdist_egg --dist-dir=../tarballs \
	    upload --sign && \
	${PYTHON25} setup.py register bdist_egg --dist-dir=../tarballs \
	    upload --sign
	touch $@

test: test_tzinfo test_docs test_zdump

clean:
	rm -f .stamp-*
	rm -rf build/*/*
	make -C ${OLSON}/src clean
	find . -name \*.pyc | xargs rm -f

test_tzinfo: .stamp-tzinfo
	cd build/dist/pytz/tests && ${PYTHON} test_tzinfo.py ${TESTARGS}

test_docs: .stamp-tzinfo
	cd build/dist/pytz/tests && ${PYTHON} test_docs.py ${TESTARGS}

test_zdump: build/dist/test_zdump.py
	${PYTHON} -c \
	    'import compileall;compileall.compile_dir("build/dist/zoneinfo")'
	cd build/dist && ${PYTHON} test_zdump.py ${TESTARGS}

build/dist/test_zdump.py: .stamp-zoneinfo
	${PYTHON} gen_tests.py ${TARGET}

README.html: test_docs
	rst2html --embed-stylesheet \
	    --traceback src/README.txt > README.html

.stamp-tzinfo: .stamp-zoneinfo gen_tzinfo.py
	${PYTHON} gen_tzinfo.py ${TARGET}
	cp ${OLSON}/src/zone.tab build/dist/pytz/
	chmod u+w build/dist/pytz/zone.tab
	touch $@

.stamp-zoneinfo:
	${MAKE} -C ${OLSON}/src TOPDIR=`pwd`/build install
	touch $@

build/dist/locales/pytz.pot: .stamp-tzinfo
	${PYTHON} gen_pot.py build/dist/pytz/locales/pytz.pot

#	cd build/dist; mkdir locales; \
#	pygettext --extract-all --no-location \
#	    --default-domain=pytz --output-dir=locales



.PHONY: all check dist test test_tzinfo test_docs test_zdump
