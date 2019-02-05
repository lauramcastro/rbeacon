ERL   ?= erl
ERLC  ?= erlc
APP   := rbeacon
REBAR ?= rebar3

.PHONY: doc test

all: deps compile

compile:
	@$(REBAR) compile

deps:
	@$(REBAR) get-deps

doc: compile
	$(REBAR) edoc skip_deps=true

clean:
	@$(REBAR) clean

distclean:
	@$(REBAR) clean --all
	@rm -rf _build
	@rm -rf .eunit
	@rm -rf rebar.lock .rebar

dialyzer: compile
	$(REBAR) dialyzer

test: compile
	@$(REBAR) do eunit, cover
