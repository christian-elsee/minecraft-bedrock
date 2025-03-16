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
clean:  distclean

## workflow #####################################
distclean:
	: ## $@
	: ## Remove orchestration target
	rm -rf dist
dist:
	: ## $@
	: ## Create orchestration target
	mkdir -p $@

check:
	: ## $@
	: ## Validate orchestration target artifacts

build: dist .env
	: ## $@
	: ## Build an orchestration target
	cp .env dist
	docker compose config \
		| tee dist/docker-compose.yml
.env: .env.dist
	: ## $@
	cp $^ $@

install: dist/docker-compose.yml
	: ## $@
	: ## Deploy orchestration target
	cd dist
	docker compose up -d

clean:
	: ## $@
	: ## Remove all orchestration artifacts
	docker compose down --volumes --remove-orphans
