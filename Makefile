SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail $(if $(TRACE),-x,) -c
.DEFAULT_GOAL := all
.ONESHELL:
.DELETE_ON_ERROR:

## env ##########################################

NAME := $(shell pwd | xargs basename)

## interface ####################################
all: distclean dist check build
init:
install:
status:
clean: destroy distclean

## workflow #####################################
distclean:
	: ## $@
	: ## Remove orchestration target
	rm -rf dist
dist:
	: ## $@
	: ## Create orchestration target
	mkdir -p $@

check: docker-compose.yaml
	: ## $@
	: ## Validate orchestration target artifacts
	<$^ yq -re .

build: dist .env docker-compose.yaml
	: ## $@
	: ## Build an orchestration target
	cp .env dist
	docker compose config \
		| tee dist/docker-compose.yaml
.env: .env.dist
	: ## $@
	cp $^ $@

install: dist/docker-compose.yaml
	: ## $@
	: ## Deploy orchestration target
	cd dist

	docker network create macvlan \
	  --driver=macvlan \
	  --opt parent=$(IFACE) \
	  --subnet=192.168.86.0/24 \
	  --gateway=192.168.86.1 \
	||:
	docker compose up -d

status:
	: ## $@
	: ## Show compose project status
	docker compose ps

destroy: dist
	: ## $@
	: ## Remove all orchestration artifacts
	cd dist
	docker compose down --volumes --remove-orphans
