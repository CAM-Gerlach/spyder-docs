.PHONY: clean clean-test clean-pyc clean-build docs multidocs help
.DEFAULT_GOAL := help

define BROWSER_PYSCRIPT
import os, webbrowser, sys

from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

BROWSER := python -c "$$BROWSER_PYSCRIPT"

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean: clean-build clean-pyc clean-test ## remove all build, test, coverage and Python artifacts

autodocs: ## generate Sphinx HTML documentation, including API docs
	rm -f doc/spyder.*
	rm -f doc/modules.rst
	sphinx-apidoc -o doc/ spyder-repo/spyder/ *tests*

docs: ## generate Sphinx HTML documentation for the current branch
	$(MAKE) -C doc clean
	$(MAKE) -C doc html

multidocs: ## prepare Sphinx HTML documentation for multiversion deployment
	mkdir doc/_build/html/5
	mv doc/_build/html/* doc/_build/html/5 || true
	@python scripts/safecopy.py "5" "current" -v --base-path "doc/_build/html"
	@python scripts/generateredirects.py "current" -v --base-path "doc/_build/html" --base-url "https://docs.spyder-ide.org"

linkcheck: ## check that links are still valid
	$(MAKE) -C doc linkcheck

servedocs: doc ## compile the docs watching for changes
	watchmedo shell-command -p '*.rst' -c '$(MAKE) -C doc html' -R -D .

serve: clean ## Launch the docs in a web browser
	$(BROWSER) doc/_build/html/index.html
