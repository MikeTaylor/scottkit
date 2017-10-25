TARGET = man1/scottkit.1

$(TARGET): scottkit.md Makefile
	test -d man1 || mkdir man1
	(echo '% SCOTTKIT(1)'; sed -n '/^##/,$$p' $<) | sed 's/^#//;/^#/y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/' | pandoc -s -t man > $@

show: $(TARGET)
	man -M . scottkit

clean:
	rm -f $(TARGET)

.PHONY: show
