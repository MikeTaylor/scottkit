test: nosferatu.sao
	scottkit -W -e $< < nosferatu.sol | diff nosferatu.transcript -

nosferatu.sao: nosferatu.sck
	scottkit -c $< > $@
	diff nosferatu.regression $@

rebuild:
	scottkit -c nosferatu.sck > nosferatu.regression
	scottkit -W -e nosferatu.sao < nosferatu.sol > nosferatu.transcript

clean:
	rm -f nosferatu.sao

