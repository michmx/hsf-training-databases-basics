## ========================================
## Jupyter Book 2 commands

# Settings
JB = jupyter-book
DST = _build

# Default target
.DEFAULT_GOAL := commands

.PHONY: jb-build jb-start jb-clean commands

## * jb-build          : build Jupyter Book site (HTML)
jb-build:
	$(JB) build --html

## * jb-start          : start Jupyter Book dev server
jb-start:
	$(JB) start

## * jb-clean          : clean Jupyter Book build artifacts
jb-clean:
	@rm -rf ${DST}

## * commands          : show all commands.
commands:
	@sed -n -e '/^##/s|^##[[:space:]]*||p' $(MAKEFILE_LIST)
