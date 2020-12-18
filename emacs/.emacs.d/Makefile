# GNU Make rules for fetching and byte-compiling various elisp files.

EMACS=emacs -q --no-site-file

usage:
	@echo "usage: make [foo.el | foo.elc | autoloads | usage | all]"
	@echo "       make foo.el  will fetch foo.el from the Internet"
	@echo "       make foo.elc will byte-compile foo.el."
	@echo "                    (fetching foo.el first if necessary)."
	@echo "       make all will turn buil .elc for all .el in this dir."
	@echo "       make autoloads will update the autoloads file."
	@echo "       make usage displays this message."
	@echo

autoloads: install.el

	emacs -q --no-site-file -batch -L . -l install.el \
		-eval '(install-update-autoloads "autoloads")'


ELS = $(shell ls -1 *.el)
ELCS = $(ELS:.el=.elc)
all: $(ELCS)
	make $(ELCS)

.el.elc:
	$(EMACS) -batch -L . \
		-eval "(setq max-lisp-eval-depth 1500 max-specpdl-size 3000)" \
		-eval "(mapc (lambda (dir) (add-to-list 'load-path dir)) (parse-colon-path (getenv \"LOAD_PATH\")))" \
		-f batch-byte-compile $*.el


EMACSWIKI_DOWNLOAD=http://www.emacswiki.org/emacs/download/

# Where I most recently fetched various random elisp files written by
# other people.

autopair.el:
	curl -O https://raw.github.com/capitaomorte/autopair/master/autopair.el

auto-complete: auto-complete.el.zip
	unzip -o auto-complete.zip
	mv -f auto-complete-1.3.1 auto-complete

auto-complete.el.zip:
	curl -L http://cx4a.org/pub/auto-complete/auto-complete-1.3.1.zip -o auto-complete.zip

eproject:
	git clone git://repo.or.cz/eproject.git

install.el:
	curl -O http://www.iro.umontreal.ca/~monnier/elisp/install.el

ido.el:
	curl -O http://repo.or.cz/w/emacs.git/blob_plain/HEAD:/lisp/ido.el

helm:
	git clone https://github.com/emacs-helm/helm.git helm

icicles:
	git clone https://github.com/emacsmirror/icicles.git

globalff.el:
	curl -O http://www.emacswiki.org/emacs/download/globalff.el

solarized:
	git clone https://github.com/sellout/emacs-color-theme-solarized.git

monokai.el:
	curl -O http://www.emacswiki.org/emacs/download/monokai-theme.el

projectile:
	git clone https://github.com/bbatsov/projectile.git

dash:
	git clone https://github.com/magnars/dash.el.git dash

s:
	git clone https://github.com/magnars/s.el.git s

ag:
	git clone https://github.com/Wilfred/ag.el.git ag

highlight-symbol:
	git clone https://github.com/nschum/highlight-symbol.el.git highlight-symbol

iedit:
	git clone https://github.com/victorhge/iedit.git iedit
