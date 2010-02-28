# This rebuilds the files used for regression testing
# Do this ONLY WHEN SURE that the software is correct

RUN = ruby1.9 -I ../../../lib ../../../bin/scottkit

**default**:
	@echo "Use 'make rebuild' if you are SURE that the software is correct"

rebuild:
	for i in 01 02 04; do \
		$(RUN) -e -s 12368 -W ../../adams/adv$$i.dat < adv$$i.solution > adv$$i.transcript; \
		md5sum adv$$i.transcript | sed 's/ .*//' > adv$$i.transcript.md5; \
	done
