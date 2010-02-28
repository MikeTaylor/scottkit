# See comments for ../adams/Makefile

1_baton.dat: mysterious.tar.gz
	tar xzf mysterious.tar.gz

mysterious.tar.gz:
	wget -nv http://ifmirror.russotto.net/if-archive/scott-adams/games/scottfree/mysterious.tar.gz

clean:
	rm -f ReadMe.txt *.dat

realclean: clean
	rm -f mysterious.tar.gz

