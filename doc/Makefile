#
#
# $Id: Makefile,v 1.1 2000/12/10 08:20:36 konst Exp $

DSL=konst.dsl
MAIN=Asmutils-HOWTO
SGML=$(MAIN).sgml
HTMLDIR=html

all:	html

html:	$(SGML) $(DSL)
	jade -t sgml -ihtml -d $(DSL)\#html $(SGML)
	mkdir -p $(HTMLDIR)
	mv *.htm* $(HTMLDIR)

rtf:	$(SGML) $(DSL)
	jade -t rtf -d $(DSL)\#print $(SGML)

pdf:	$(SGML) $(DSL)
	jade -t tex -d $(DSL)\#print $(SGML)
#
# three passes are needed to generate proper page numbers in toc
#
	pdfjadetex $(MAIN).tex
	pdfjadetex $(MAIN).tex
	pdfjadetex $(MAIN).tex

clean:
	rm -rf $(HTMLDIR) *.htm* *.rtf *.tex *.pdf *.aux *.log
