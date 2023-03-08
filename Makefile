ZPICO_ROOT:=$(realpath $(dir $(lastword $(MAKEFILE_LIST))))
SHOVE_URL:=https://github.com/progrhyme/shove.git
SHOVE_DIR:=$(ZPICO_ROOT)/.ignore/shove
TEST?=test

.PHONY: shove test help

shove:
	mkdir -p $(SHOVE_DIR)
	git clone $(SHOVE_URL) $(SHOVE_DIR)
	chmod 755 $(SHOVE_DIR)/bin/shove

test:
	ZPICO_ROOT=$(ZPICO_ROOT) $(SHOVE_DIR)/bin/shove -r $(TEST) -s zsh

help: ## Self-documented Makefile
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
