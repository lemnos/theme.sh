awk '
function escape(s) {
	if(ENVIRON["TMUX"])
		return sprintf("\033Ptmux;\033%s\033\\", s)
	else
		return s
}

function read() {
	# Read until we encounter the CSI response, indicates end of
	# stream (assumes fifo request-response output)

	buf = ""
	while((end=index(buf, "[")) == 0) {
		cmd=sprintf("dd if=/dev/tty ibs=1024 count=1 2> /dev/null")
		cmd|getline c
		buf = buf c
	}

	print buf > "/tmp/1"
	return substr(buf, 1, end)
}

function parse_seq(s) {
	if(match(s, /rgb:/)) {
		key = substr(s, 1, RSTART-1)

		r=substr(s, RSTART+4, 2)
		g=substr(s, RSTART+9, 2)
		b=substr(s, RSTART+14, 2)

		colors[key] = "#" r g b
	}
}

function get_seq(s) {
	printf sprintf("\033]%s;?\007", s) > "/dev/tty"
	printf sprintf("\033]%s;?\007", s) > "/tmp/2"
	printf "\033[c" > "/dev/tty"
	print sprintf("\033]%s;?\007", s) >> "/tmp/i"
	buf = read()
	print buf >> "/tmp/o"
	parse_seq(substr(buf,2))
}

BEGIN {
	system("stty cbreak -echo")
	get_seq("11")
	get_seq("10")
	get_seq("12")
	system("stty -cbreak echo")
	for(c in colors)
			printf "%s %s\n", c, colors[c];

#	for(i=0;i<16;i++)
#		printf escape(sprintf("\033]4;%d;?\007", i)) > "/dev/tty"
#
#	printf escape("\033]10;?\007") > "/dev/tty"
#	printf escape("\033]11;?\007") > "/dev/tty"
#	printf escape("\033]12;?\007") > "/dev/tty"
#
#	# Terminating CSI sequence, should be supported on all
#	# terminals. Ensures we do not block forever waiting for
#	# input on unsupported terms.
#
#	buf = read()
#
#	system("stty -raw echo")
#
#	split(buf, responses, "]")
#	for(i in responses)
#		parse_seq(responses[i])
#
#	for(i=0;i<16;i++)
#		printf "%d: %s\n", i, colors[sprintf("4;%d;", i)]
#
#	printf "foreground: %s\n", colors["10;"]
#	printf "background: %s\n", colors["11;"]
#	printf "cursor: %s\n", colors["12;"]
}
'
