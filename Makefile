# http://artofawk.net/?tdd and tim@menzies.us
# usage:
#
# make: only display summary
# make watch: verbose run, no summary
# make
# 
egs=eg
tmp=$(HOME)/tmp
do=1

tests = $(shell ( [ -d "$(egs)" ] && cd $(egs); ls|egrep '^[0-9]+$$' |sort -n ) )

##### run all tests
all:
	@$(MAKE) watch |gawk '/^(PASS|FAIL)/{print $$1}' |sort |uniq -c 

watch:  setup tests teardown

tests:
	@echo Running $(tests)
	@-$(foreach x, $(tests), $(MAKE) do=$x test;)

#### run one test, compare its output to some ${egs}/*.want entry
test    : setup dotest teardown 
setup   :; @ if [ -f "$(egs)/$@" ]; then cd $(egs) ; ./$@; fi
teardown:; @ if [ -f "$(egs)/$@" ]; then cd $(egs) ; ./$@; fi

dotest : $(tmp)   $(egs)/$(do).want
	@$(MAKE) --no-print-directory run | tee $(tmp)/$(do).got 
	@if diff -u -s $(tmp)/$(do).got $(egs)/$(do).want > $(tmp)/$(do).diff ;  \
        then echo PASS $(do) ; \
        else echo FAIL $(do),  got $(tmp)/$(do).got see $(tmp)/$(do).diff; \
        fi

# run a test, cache the result as a ${egs}/$(do).want file
cache :	$(egs)/$(do)
	@$(MAKE) --no-print-directory run  | tee $(egs)/$(do).want
	@echo new test result cached to $(egs)/$(do).want

# low level workers
run :
	@printf "\n---| $(do) |-----------------------------------------\n\n"﻿  
	@cd $(egs) ; ./$(do)

$(tmp): ; echo 2; @- [ ! -d "$@" ] && mkdir -p "$@"
