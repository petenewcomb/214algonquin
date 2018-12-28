SHELL=/bin/bash

.PHONY: all
all: dolbyatmos.stl

.PHONY: force

include $(wildcard *.deps)

%.stl: %.scad
	openscad -m make -o $@ -d $@.deps $<


PAGE_WIDTH = 11
PAGE_HEIGHT = 8.5
PAGE_MARGIN = 0.25

RAILINGS = $(wildcard railing-*.scad)


.PRECIOUS: railing-%.raw.svg
railing-%.raw.svg: railing-%.scad railing.scad
	openscad -o $@ $<

railings.pdf: $(RAILINGS:%.scad=%.pdf)
	pdfunite $(RAILINGS:%.scad=%.pdf) $@

.PRECIOUS: railing-%.svg
railing-%.svg: railing-%.raw.svg force
	sed 's;^" stroke="black" fill="lightgray" stroke-width="0.5"/></svg>$$;" stroke="none" fill="black"/></svg>;' <$< | awk -vFPAT='-?[0-9.]+' '/^<svg width="[0-9.]+" height="[0-9.]+" viewBox="-?[0-9.]+ -?[0-9.]+ [0-9.]+ [0-9.]+" xmlns="http:\/\/www\.w3\.org\/2000\/svg" version="1\.1">$$/{pw=$(PAGE_WIDTH)-2*$(PAGE_MARGIN); o2in=pw/$$5; in2u=1/o2in; sf=$(PAGE_WIDTH)/pw; printf("<svg width=\"$(PAGE_WIDTH)in\" height=\"$(PAGE_HEIGHT)in\" viewBox=\"%g %g %g %g\" xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\">",($$3*o2in-$(PAGE_MARGIN))*in2u,($$4*o2in-$(PAGE_MARGIN))*in2u,$$5*sf,$(PAGE_HEIGHT)*in2u);next};{print}' >$@

.PRECIOUS: railing-%.pdf
railing-%.pdf: railing-%.svg force
	rm -rf $@.d; set -e; mkdir $@.d; rsvg-convert -f pdf -d 72 -p 72 -o $@.d/$@.1 $<; awk -vFPAT='-?[0-9.]+' '/^<svg/{pw=$(PAGE_WIDTH)-2*$(PAGE_MARGIN); o2in=pw/$$5; in2u=1/o2in; sf=$(PAGE_WIDTH)/pw; h=$$6*o2in; ph=$(PAGE_HEIGHT)-2*$(PAGE_MARGIN); nf=h/ph; n=int(nf); if (nf>n) n++; if (n==1) {print 0, 0} else {print n-1, (ph-(n*ph-h)/(n-1))*in2u}}' railing-$*.raw.svg | (set -e; read n o; for ((i=0; i<n; i++)) do awk -vFPAT='-?[0-9.]+' -vi="$$i" -vo="$$o" '/^<svg /{$$0=gensub(/(viewBox="-?[0-9.]+ )(-?[0-9.]+)( [0-9.]+ [0-9.]+")/,sprintf("\\1%g\\3",$$4+(i+1)*o),1)};{print}' $< >$@.d/railing-$*.svg.$$((i+2)); rsvg-convert -f pdf -o $@.d/$@.$$((i+2)) $@.d/railing-$*.svg.$$((i+2)); done); pdfunite $@.d/$@.* $@
