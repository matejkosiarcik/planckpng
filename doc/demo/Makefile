# Helper Makefile to group scripts for development

MAKEFLAGS += --warn-undefined-variables
PROJECT_DIR := $(dir $(abspath $(MAKEFILE_LIST)))
AZLINT_VERSION ?= dev
DESTDIR ?= $$HOME/bin
SHELL := /bin/sh
.SHELLFLAGS := -ec
ACTIVATE_VENV := [ -n "$${VIRTUAL_ENV+x}" ] || . ./venv/bin/activate
# PATH:="$(shell echo "$$PATH"):$(PROJECT_DIR)/node_modules/.bin"

.POSIX:

.DEFAULT: all
.PHONY: all
all: bootstrap record

.PHONY: bootstrap
bootstrap:
	# JS
	npm ci

	# python
	# check if virtual environment exists or create it
	[ -n "$${VIRTUAL_ENV+x}" ] || [ -d venv ] \
		|| python3 -m venv venv \
		|| python -m venv venv \
		|| virtualenv venv \
		|| mkvirtualenv venv
	# install dependencies into existing or created virtual environment
	if $(ACTIVATE_VENV); then \
		python -m pip install --requirement requirements.txt && \
		gitman install \
	;else exit 1; fi

.PHONY: record
record:
	if $(ACTIVATE_VENV); then \
		PATH="$$PATH:$(PROJECT_DIR)/node_modules/.bin" sh main.sh \
	;else exit 1; fi
