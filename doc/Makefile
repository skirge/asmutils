#
#
# $Id: Makefile,v 1.2 2002/08/14 16:55:30 konst Exp $

DSL=konst.dsl
MAIN=Asmutils-HOWTO
SGML=$(MAIN).sgml
TEXI=sha1sum.texi
HTMLDIR=html

all:	html

html:	$(SGML) $(DSL) $(TEXI)
	jade -t sgml -ihtml -d $(DSL)\#html $(SGML)
	texi2html $(TEXI)
	mkdir -p $(HTMLDIR)
	mv *.htm* $(HTMLDIR)

rtf:	$(SGML) $(DSL) $(TEXI)
	jade -t rtf -d $(DSL)\#print $(SGML)

pdf:	$(SGML) $(DSL) $(TEXI)
	jade -t tex -d $(DSL)\#print $(SGML)
#
# three passes are needed to generate proper page numbers in toc
#
	pdfjadetex $(MAIN).tex
	pdfjadetex $(MAIN).tex
	pdfjadetex $(MAIN).tex

	texi2pdf $(TEXI)

clean:
	rm -rf $(HTMLDIR) *.htm* *.rtf *.tex *.pdf *.aux *.log
