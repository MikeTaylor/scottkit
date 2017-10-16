# This rebuilds the files used for regression testing
# Do this ONLY WHEN SURE that the software is correct

RUN = ruby -I ../../lib ../../bin/scottkit

**default**:
	@echo "Use 'make rebuild' if you are SURE that the software is correct"

rebuild: rebuild-decompile rebuild-play

rebuild-decompile:
	$(RUN) -d ../adams/adv01.dat > adv01.decompile

rebuild-play:
	$(RUN) -e -s 12368 -W -f crystal.solution crystal.sao > crystal.transcript
	$(RUN) -e -s 12368 -W -f t7.solution t7.sao > t7.transcript

.PHONY: rebuild rebuild-decompile rebuild-play

