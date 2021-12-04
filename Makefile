all:
	-mkdir -p bin 
	cp src/theme.sh bin/theme.sh
	chmod +x bin/theme.sh
	./bin/theme.sh -a themes/*
