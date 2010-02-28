# This rebuilds the files used for regression testing
# Do this ONLY WHEN SURE that the software is correct

RUN = ruby1.9 -I ../../lib ../../bin/scottkit

**default**:
	@echo "Use 'make rebuild' if you are SURE that the software is correct"

rebuild: rebuild-decompile rebuild-play

rebuild-decompile:
	$(RUN) -d ../adams/adv01.dat > adv01.decompile

rebuild-play:
	### Rebuild crystal, etc.

.PHONY: rebuild rebuild-decompile rebuild-play

