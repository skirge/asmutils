<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY % html "IGNORE">
<![%html;[
<!ENTITY % print "IGNORE">
<!ENTITY docbook.dsl PUBLIC "-//Norman Walsh//DOCUMENT DocBook HTML Stylesheet//EN" CDATA dsssl>
<!--<!ENTITY dbstyle SYSTEM "/usr/local/lib/sgml/html/docbook.dsl" CDATA DSSSL>-->
]]>
<!ENTITY % print "INCLUDE">
<![%print;[
<!ENTITY docbook.dsl PUBLIC "-//Norman Walsh//DOCUMENT DocBook Print Stylesheet//EN" CDATA dsssl>
<!--<!ENTITY dbstyle SYSTEM "/usr/local/lib/sgml/print/docbook.dsl" CDATA DSSSL>-->
]]>
]>

<!--
	$Id: konst.dsl,v 1.1 2000/12/10 08:20:36 konst Exp $
-->

<style-sheet>

<style-specification id="print" use="docbook">
<style-specification-body> 

(declare-characteristic preserve-sdata?
  ;; this is necessary because right now jadetex does not understand
  ;; symbolic entities, whereas things work well with numeric entities.
  "UNREGISTERED::James Clark//Characteristic::preserve-sdata?"
  #f)

	(define %generate-article-toc% #t)
	(define (toc-depth nd) 2)
	(define %generate-article-titlepage-on-separate-page% #t)
	(define %section-autolabel% #t)
	(define %footnote-ulinks% #f)
	(define %bop-footnotes% #f)
	(define %body-start-indent% 0pi)
	(define %para-indent-firstpara% 0pt)
	(define %para-indent% 0pt)
	(define %block-start-indent% 0pt)
	(define formal-object-float #t)
	(define %hyphenation% #t)
	(define %admon-graphics% #f)
</style-specification-body>
</style-specification>

<style-specification id="html" use="docbook">
<style-specification-body> 

(declare-characteristic preserve-sdata?
  ;; this is necessary because right now jadetex does not understand
  ;; symbolic entities, whereas things work well with numeric entities.
  "UNREGISTERED::James Clark//Characteristic::preserve-sdata?"
  #f)

	(define %generate-legalnotice-link% #f)
	(define %admon-graphics-path% "../images/")
	(define %admon-graphics% #f)
		;; make funcsynopsis look pretty
	(define %funcsynopsis-decoration% #t)
	(define %html-ext% ".html")
	(define %generate-article-toc% #t)
	(define %generate-part-toc% #t)
	(define %generate-article-titlepage% #t)
		;; forces the Table of Contents on separate page
;;	(define (chunk-skip-first-element-list) '())
;;	(define %root-filename% "index")
;;	(define %body-attr% '())
;;	(define %shade-verbatim% #t)
	(define %use-id-as-filename% #t)
	(define %graphic-default-extension% "gif")
	(define %gentext-nav-tblwidth% "100%")
	(define %section-autolabel% #t)
	(define (toc-depth nd) 2)
		;; more depth, 2 levels, to toc, instead of flat hierarchy
</style-specification-body>
</style-specification>

<!--<external-specification id="docbook" document="dbstyle">-->
<external-specification id="docbook" document="docbook.dsl">
</style-sheet>
