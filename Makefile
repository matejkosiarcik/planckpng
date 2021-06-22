# Helper Makefile to group scripts for development

MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/sh
.SHELLFLAGS := -ec
PROJECT_DIR := $(dir $(abspath $(MAKEFILE_LIST)))

.POSIX:

.DEFAULT: all
.PHONY: all
all: bootstrap build

.PHONY: bootstrap
bootstrap:
	npm --prefix test ci

.PHONY: build
build:
	docker build . --tag matejkosiarcik/millipng:dev

.PHONY: test
test:
	npm --prefix test test

.PHONY: test-lite
test-lite:
	npm --prefix test run test-lite

.PHONY: doc
doc:
	@$(MAKE) -C$(PROJECT_DIR)/doc/demo bootstrap record
