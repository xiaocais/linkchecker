VERSION=$(shell ./setup.py --version)
#HOST=treasure.calvinsplayground.de
PROXY=
#PROXY=-P$(HOST):5050
HOST=fsinfo.cs.uni-sb.de
#PROXY=-Pwww-proxy.uni-sb.de:3128
PACKAGE = linkchecker
DEBPACKAGE = $(PACKAGE)_$(VERSION)_i386.deb
ALLPACKAGES = ../$(DEBPACKAGE)
DESTDIR=/.
.PHONY: test clean files homepage dist install all
TAR = tar
ZIP = zip

all:

clean:
	./setup.py clean --all
	rm -rf $(ALLPACKAGES) $(PACKAGE)-out.*

install:
	./setup.py install --prefix=/tmp/usr --exec-prefix=/tmp/usr
	# do what I mean, Distutils!
	cp -a /tmp/usr/* $(DESTDIR)/usr
	# remove following line if Distutils have script support
	install -c -m 755 linkchecker $(DESTDIR)/usr/bin/
	install -c -m 644 linkcheckerrc $(DESTDIR)/etc/
	install -c -m 644 DNS/README $(DESTDIR)/usr/share/doc/$(PACKAGE)/README.dns

dist:
	./setup.py sdist
	fakeroot debian/rules binary
        
files:
	./$(PACKAGE) -Ftext -Fhtml -Fgml -Fsql -R -t0 -v $(PROXY) -i$(HOST) http://$(HOST)/~calvin/

homepage:
	scp debian/changelog shell1.sourceforge.net:/home/groups/linkchecker/htdocs/changes.txt

test:
	rm -f test/*.result
	@for i in test/*.html; do \
	  echo "Testing $$i. Results are in $$i.result"; \
	  ./$(PACKAGE) -t0 -N"news.rz.uni-sb.de" -v -a $$i > $$i.result 2>&1; \
        done
