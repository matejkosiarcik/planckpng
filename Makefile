# Helper Makefile to group scripts for development

MAKEFLAGS += --warn-undefined-variables
PROJECT_DIR := $(dir $(abspath $(MAKEFILE_LIST)))
AZLINT_VERSION ?= dev
DESTDIR ?= $${HOME}/bin
SHELL := /bin/sh
.SHELLFLAGS := -ec

.POSIX:

.DEFAULT: all
.PHONY: all
all: build

.PHONY: bootstrap
bootstrap:
	npm --prefix test install

.PHONY: build
build:
	cd docker && $(MAKE) build

.PHONY: test
test:
	npm --prefix test test
