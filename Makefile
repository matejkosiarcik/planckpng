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
	npm ci --prefix tests
	npm ci --prefix dependencies

.PHONY: build
build:
	docker build . --tag matejkosiarcik/planckpng:dev

.PHONY: test
test:
	npm test --prefix tests

.PHONY: test-full
test-full:
	npm run test:full --prefix tests

.PHONY: demo
demo:
	@$(MAKE) -C$(PROJECT_DIR)/docs/demo bootstrap record
