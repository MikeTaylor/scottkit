# This Makefile fetches an archive of Scott Adams's games from a
# well-known location and unpacks it; make clean removes the unpacked
# file and make realclean also removes the downloaded archive.  I
# don't want to include the Adams games in the ScottKit distribution,
# as they are still under copyright and not really mine to distribute.

adv01.dat: AdamsGames.zip
	unzip -o AdamsGames.zip

AdamsGames.zip:
	wget -nv http://ifmirror.russotto.net/if-archive/scott-adams/games/scottfree/AdamsGames.zip

clean:
	rm -f 0readme.txt *.dat

realclean: clean
	rm -f AdamsGames.zip

