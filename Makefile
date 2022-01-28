.PHONY: test init

init:
	git submodule init # initialize test/test_helpers for bats
	git submodule update # might as well git pull helpers
test: init
	bats ./test.bats --print-output-on-failure