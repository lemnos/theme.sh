all:
	cp theme_base.sh theme.sh
	chmod +x theme.sh
	./theme.sh -a themes/*
