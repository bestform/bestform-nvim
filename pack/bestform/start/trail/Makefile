PLUGIN_ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

.PHONY: test

test:
	@set -e; cd "$(PLUGIN_ROOT)" && for f in tests/trail_*_spec.lua; do \
		nvim --headless -u NONE -c "lua dofile('$$f')" -c "qa!"; \
	done
