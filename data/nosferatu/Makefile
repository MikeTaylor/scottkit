test: nosferatu.sao
	scottkit -e $< < nosferatu.sol | diff nosferatu.script -

nosferatu.sao: nosferatu.sck
	scottkit -c $< > $@
	diff nosferatu.regression $@

clean:
	rm -f nosferatu.sao

