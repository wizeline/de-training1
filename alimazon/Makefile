VIRTUAL_ENV := training

.PHONY: build gh-deploy serve help clean

build:
	mkdocs build

clean:
	find . -name '*.pyc' -exec rm --force {} +
	find . -name '*.pyo' -exec rm --force {} +
	rm -rf ./site/

help:
	@echo 'Commands:'
	@echo '    build    Build the MkDocs documentation'
	@echo '    clean    Remove created artifacts'
	@echo '    help     Show this message'
	@echo '    serve    Run the builtin development server'

serve:
	mkdocs serve

