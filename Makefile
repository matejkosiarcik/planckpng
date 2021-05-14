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
	npm --prefix test ci

.PHONY: build
build:
	docker build . --tag matejkosiarcik/millipng:dev

.PHONY: test
test:
	npm --prefix test test

.PHONY: record-bootstrap
record-bootstrap:
	npm --prefix record ci

.PHONY: record
record:
	sh record/run.sh
