CLEANFILES = $(strings_DATA)
EXTRA_DIST = $(strings_DATA)
stringsdir = $(ABIWORD_DATADIR)/strings

UIBACKPORT = $(srcdir)/ui-backport.pl

strings_DATA = \
	af-ZA.strings \
	am-ET.strings \
	ar.strings \
	ast-ES.strings \
	ayc-BO.strings \
	aym-BO.strings \
	be-BY.strings \
	be@latin.strings \
	bg-BG.strings \
	br-FR.strings \
	ca-ES.strings \
	cs-CZ.strings \
	cy-GB.strings \
	da-DK.strings \
	de-CH.strings \
	de-DE.strings \
	el-GR.strings \
	en-AU.strings \
	en-CA.strings \
	en-GB.strings \
	en-IE.strings \
	eo.strings \
	es-ES.strings \
	es-MX.strings \
	et.strings \
	eu-ES.strings \
	ff.strings \
	fi-FI.strings \
	fr-FR.strings \
	ga-IE.strings \
	gl.strings \
	he-IL.strings \
	hr-HR.strings \
	hu-HU.strings \
	id-ID.strings \
	it-IT.strings \
	ja-JP.strings \
	jbo.strings \
	kk-KZ.strings \
	ko.strings \
	ku.strings \
	lt-LT.strings \
	lv-LV.strings \
	mg-MG.strings \
	mk-MK.strings \
	mnk-SN.strings \
	ms-MY.strings \
	nb-NO.strings \
	ne-NP.strings \
	nl-NL.strings \
	nn-NO.strings \
	pl-PL.strings \
	ps.strings \
	pt-BR.strings \
	pt-PT.strings \
	quh-BO.strings \
	qul-BO.strings \
	ro-RO.strings \
	ru-RU.strings \
	sc-IT.strings \
	sk-SK.strings \
	sl-SI.strings \
	sq-AL.strings \
	sr@latin.strings \
	sr.strings \
	sv-SE.strings \
	ta-IN.strings \
	tr-TR.strings \
	uk-UA.strings \
	vi-VN.strings \
	wo-SN.strings \
	yi.strings \
	zh-CN.strings \
	zh-HK.strings \
	zh-TW.strings 

.po.strings:
	$(UIBACKPORT) $< $@
