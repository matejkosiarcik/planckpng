# Helper Makefile to group scripts for development

MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/sh
.SHELLFLAGS := -ec
PROJECT_DIR := $(abspath $(dir $(MAKEFILE_LIST)))

.POSIX:

.DEFAULT: all
.PHONY: all
all: bootstrap build

.PHONY: bootstrap
bootstrap:
	npm --prefix test ci

.PHONY: build
build:
	docker build . --tag matejkosiarcik/planckpng:dev

.PHONY: test
test:
	npm --prefix test test

.PHONY: test-lite
test-lite:
	npm --prefix test run test-lite

.PHONY: demo
demo:
	@$(MAKE) -C$(PROJECT_DIR)/docs/demo bootstrap record
