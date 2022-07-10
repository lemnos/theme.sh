#!/bin/sh

# Written by Aetnaeus.
# Source: https://github.com/lemnos/theme.sh.
# Licensed under the WTFPL provided this notice is preserved.

# Find a broken theme? Want to add a missing one? PRs are welcome.

VERSION=v1.1.5

# Use truecolor sequences to simulate the end result.

preview() {
	awk -F": " -v target="$1" '
		BEGIN {
			"tput cols" | getline nc
			"tput lines" | getline nr
			nc = int(nc)
			nr = int(nr)
		}

		/^# Themes/ { start++;next }
		!start { next }

		function hextorgb(s) {
			hexchars = "0123456789abcdef"
			s = tolower(s)

			r = (index(hexchars, substr(s, 2, 1))-1)*16+(index(hexchars, substr(s, 3, 1))-1)
			g = (index(hexchars, substr(s, 4, 1))-1)*16+(index(hexchars, substr(s, 5, 1))-1)
			b = (index(hexchars, substr(s, 6, 1))-1)*16+(index(hexchars, substr(s, 7, 1))-1)
		}

		function fgesc(col) {
			hextorgb(col)
			return sprintf("\x1b[38;2;%d;%d;%dm", r, g, b)
		}

		function bgesc(col) {
			hextorgb(col)
			return sprintf("\x1b[48;2;%d;%d;%dm", r, g, b)
		}

		$0 == target {s++}

		s && /^foreground:/ { fg = $2 }
		s && /^background:/ { bg = $2 }
		s && /^[0-9]+:/ { a[$1] = $2 }

		/^ *$/ {s=0}

		function puts(s,   len,   i,   normesc,   filling) {
			normesc = sprintf("\x1b[0m%s%s", fgesc(fg), bgesc(bg))

			len=s
			gsub(/\033\[[^m]*m/, "", len)
			len=length(len)

			filling=""
			for(i=0;i<(nc-len);i++) filling=filling" "

			printf "%s%s%s%s\n", normesc, s, normesc, filling, ""
			nr--
		}

		END {
			puts("")
			for (i = 0;i<16;i++)
				puts(sprintf("  %s Color %d\x1b[0m", fgesc(a[i]), i))

			# Note: Some terminals use different colors for bolded text and may produce slightly different ls output.

			puts("")
			puts(" # ls --color -F")
			puts(sprintf("    file"))
			puts(sprintf("    \x1b[1m%sdir/", fgesc(a[4])))
			puts(sprintf("    \x1b[1m%sexecutable", fgesc(a[10])))
			puts(sprintf("    \x1b[1m%ssymlink\x1b[0m%s%s", fgesc(a[6]), fgesc(fg), bgesc(bg)))


			while(nr > 0) puts("")

			printf "\x1b[0m"
		}
	' < "$0"
}

# Alphabetize and dedupe theme list.

normalize_themes() {
	awk '
		# We could eliminate the sorting logic by using gnu extensions but that would reduce portability.

		function cmp(a,b,ordTbl,    i,c1,c2,n) {
			n = length(a) > length(b) ? length(b) : length(a)
			for(i = 1;i <= n;i++) {
				c1 = substr(a, i, 1)
				c2 = substr(b, i, 1)

				if(c1 != c2)
					return ordTbl[c1] < ordTbl[c2]
			}

			return length(a) < length(b)
		}

		function sort(a,n,    i,j,tmp,ordTbl) {
			 for(i = 0;i < 256;i++) ordTbl[sprintf("%c", i)] = i

			for(i = 0;i < n;i++) {
				tmp = a[i]
				j = i-1
				while(j >= 0 && cmp(tmp, a[j], ordTbl)) {
					a[j+1] = a[j]
					j--
				}

				a[j+1] = tmp
			}
		}

		function sortKeys(a,keys,    n,k) {
			for(k in a)
				keys[n++] = k
			sort(keys, n)
			return n
		}

		/^ *$/ { inTheme = 0;next }
		!inTheme { name = $0;inTheme=1;themes[name] = "";next }
		inTheme { themes[name] = themes[name]$0"\n" }

		END {
			n = sortKeys(themes, names)

			print ""
			for(i = 0;i < n;i++) {
				print names[i]
				print tolower(themes[names[i]])
			}
		}
	' "$@"
}

# Generate themes from one or more supplied kitty config files.

generate_themes() {
	awk -v argc=$# '
		function chkProp(prop) {
			if(!props[prop]) {
				printf "ABORTING: %s is missing required property '\''%s'\''\n", currentFile, prop > "/dev/stderr"
				aborted++
				exit -1
			}
		}

		function printTheme(    name,i,prop) {
			name = currentFile
			gsub(/.*\//, "", name)
			gsub(/\.conf$/, "", name)

			print name

			for (i = 0;i < 16;i++) {
				prop = sprintf("color%d", i)

				chkProp(prop)
				printf "%d: %s\n", i, props[prop]
			}

			chkProp("foreground")
			chkProp("background")
			chkProp("cursor")

			print "foreground: "props["foreground"]
			print "background: "props["background"]
			print "cursor: "props["cursor"]
			print ""
		}

		FILENAME != currentFile {
			if(currentFile)
				printTheme()

			currentFile = FILENAME
			delete props
		}

		{ props[$1] = $2 }

		END { if(!aborted) printTheme() }
	' "$@"
}

# Add themes to the script from one or more supplied kitty config files.

add() {
	tmp1="$(mktemp)"
	tmp2="$(mktemp)"

	awk 'i { print } /^# Themes/ { i++ }' "$0" > "$tmp1"
	echo "" >> "$tmp1"
	generate_themes "$@" >> "$tmp1" || exit $?

	awk '{print} /^# Themes/ { exit }'  "$0" > "$tmp2"
	normalize_themes "$tmp1" >> "$tmp2"


	rm "$tmp1"
	cat "$tmp2" > "$0" || exit $?

	printf 'Successfully annexed %d themes. More! Feed me more!\n' $#
}

preview2() {
	INHIBIT_THEME_HIST=1 "$0" "$1"

	printf '\033[30mColor 0\n'
	printf '\033[31mColor 1\n'
	printf '\033[32mColor 2\n'
	printf '\033[33mColor 3\n'
	printf '\033[34mColor 4\n'
	printf '\033[35mColor 5\n'
	printf '\033[36mColor 6\n'
	printf '\033[37mColor 7\n'

	printf '\033[90mColor 8\n'
	printf '\033[91mColor 9\n'
	printf '\033[92mColor 10\n'
	printf '\033[93mColor 11\n'
	printf '\033[94mColor 12\n'
	printf '\033[95mColor 13\n'
	printf '\033[96mColor 14\n'
	printf '\033[97mColor 15\n'

	printf '\n\033[0m'
	printf '# ls --color -F\n'
	printf '    file\n'
	printf '    \033[01;34mdir/\033[0m\n'
	printf '    \033[01;32mexecutable\033[0m*\n'
	printf '    \033[01;36msymlink\033[0m\n'

	printf '\033[0m'
}

# Consumes a theme.sh definition from STDIN and applies it.

apply_theme() {
awk '
	function tmuxesc(s) { return sprintf("\033Ptmux;\033%s\033\\", s) }
	function normalize_term() {
		# Term detection voodoo

		if(ENVIRON["TERM_PROGRAM"] == "iTerm.app")
			term="iterm"
		else if(ENVIRON["TMUX"]) {
			"tmux display-message -p \"#{client_termname}\"" | getline term
			"tmux display-message -p \"#{client_termtype}\"" | getline termname

			if(substr(termname, 1, 5) == "iTerm")
				term="iterm"
			is_tmux++
		} else
			term=ENVIRON["TERM"]
	}

	BEGIN {
		normalize_term()

		if(term == "iterm") {
			bgesc="\033]Ph%s\033\\"
			fgesc="\033]Pg%s\033\\"
			colesc="\033]P%x%s\033\\"
			curesc="\033]Pl%s\033\\"
		} else {
			#Terms that play nice :)

			fgesc="\033]10;#%s\007"
			bgesc="\033]11;#%s\007"
			curesc="\033]12;#%s\007"
			colesc="\033]4;%d;#%s\007"
		}

		if(is_tmux) {
			fgesc=tmuxesc(fgesc)
			bgesc=tmuxesc(bgesc)
			curesc=tmuxesc(curesc)
			colesc=tmuxesc(colesc)
		}
	}

	/^foreground:/ { printf fgesc, substr($2, 2) > "/dev/tty" }
	/^background:/ { printf bgesc, substr($2, 2) > "/dev/tty" }
	/^cursor:/ { printf curesc, substr($2, 2) > "/dev/tty" }
	/^[0-9]+:/ { printf colesc, $1, substr($2, 2) > "/dev/tty" }
'
}

# Sets the current theme given a name and does the requisite bookkeeping.

set_current_theme() {
	awk -F": " -v target="$1" -v script="$0" '
		/^# Themes/ { start++;next; }
		!start { next }

		$0 == target { found++;next; }

		found { theme = theme $0 "\n" }
		found && /^ *$/ { exit }

		END {
			if(found) {
				printf "%s", theme | script

				config_dir = (ENVIRON["XDG_CONFIG_HOME"] ?  ENVIRON["XDG_CONFIG_HOME"] : ENVIRON["HOME"])

				histfile = config_dir"/.theme_history"
				inhibit_hist=ENVIRON["INHIBIT_THEME_HIST"]

				if(!inhibit_hist) {
					while((getline < histfile) > 0)
						if($0 != target)
							out = out $0 "\n"
					close(histfile)

					out = out target
					print out > histfile
				}
			} else {
					printf "Theme not found: %s\n", target > "/dev/stderr"
					exit(-1)
			}
		}
	' < "$0"
}

# Dump the current theme in a format consumable by theme.sh
# by attempting to read it from the terminal.
#
# NOTE: Many terms don't support this properly (e.g alacritty)

# Refs

# https://github.com/microsoft/terminal/issues/3718
# https://github.com/alacritty/alacritty/blob/master/alacritty_terminal/src/ansi.rs#L972

print_current_theme() {
	awk '
	function print_response(s) {
		names["10;"] = "foreground"
		names["11;"] = "background"
		names["12;"] = "cursor"
		for (i = 0; i < 16; i++)
			names[sprintf("4;%d;", i)] = i

		split(s, a, "]")
		for (i in a) {
			if (match(a[i], /rgb:/)) {
				key = substr(a[i], 1, RSTART-1)

				r=substr(a[i], RSTART+4, 2)
				g=substr(a[i], RSTART+9, 2)
				b=substr(a[i], RSTART+14, 2)

				printf "%s: %s\n", names[key], "#"r g b
			}
		}
	}

	# We cant just use RS/getline for this since
	# mawk does input buffering :(.

	function read_response() {
		buf = ""

		# Accrue data until we encounter the terminating CSI response
		while ((end=index(buf,"[")) == 0) {
			# poor POSIX mans read :/
			cmd="dd if=/dev/tty bs=1024 count=1 2> /dev/null"

			while (cmd|getline data)
				buf = buf data

			close(cmd)
		}

		buf = substr(buf, 1, end-1)
		return buf
	}

	BEGIN {
		system("stty cbreak -echo")

		tty = "/dev/tty"

		# Yo dawg, I heard you like multiplexers...
		if (ENVIRON["TMUX"]) {
			# If we are running inside tmux we sent the request sequences
			# to the currently attached terminal. Note that we still
			# read the result from the virtual terminal.

			# Flow:
			# theme.sh (request) -> tty (response) -> pts (response) -> theme.sh
			# where pts is the tmux pseudoterminal.

			"tmux display-message -p \"#{client_tty}\""|getline tty
		}

		# Terminals may ignore these.

		for(i=0;i<16;i++)
			printf "\033]4;%d;?\007", i > tty

		printf "\033]10;?\007" > tty
		printf "\033]11;?\007" > tty
		printf "\033]12;?\007" > tty

		# Use a CSI DA1 sequence (supported by all terms)
		# as a sentinel value to indicate end-of-response.
		# (assumes request-response order is fifo)

		printf "\033[c" > tty

		print_response(read_response())

		system("stty -cbreak echo")
	}
	'
}

isColorTerm() {
	if [ -z "$TMUX" ]; then
		[ -n "$COLORTERM" ]
	else
		tmux display-message -p '#{client_termfeatures}'|grep -q RGB
	fi
}

list() {
	case "$filterFlag" in
		--light) filter=2 ;;
		--dark) filter=1 ;;
		*) filter=0 ;;
	esac

	awk -v filter="$filter" -F": " '
		BEGIN {
			config_dir = ENVIRON["XDG_CONFIG_HOME"] ?  ENVIRON["XDG_CONFIG_HOME"] : ENVIRON["HOME"]

			histfile = config_dir"/.theme_history"
			while((getline < histfile) > 0) {
				mru[nmru++] = $0
				mruIndex[$0] = 1
			}
		}

		function luma(s,    r,g,b,hexchars) {
			hexchars = "0123456789abcdef"
			s = tolower(s)

			r = (index(hexchars, substr(s, 2, 1))-1)*16+(index(hexchars, substr(s, 3, 1))-1)
			g = (index(hexchars, substr(s, 4, 1))-1)*16+(index(hexchars, substr(s, 5, 1))-1)
			b = (index(hexchars, substr(s, 6, 1))-1)*16+(index(hexchars, substr(s, 7, 1))-1)

			return 0.2126 * r + 0.7152 * g + 0.0722 * b
		}

		/^# Theme/ { st++;next }
		!st { next }

		/^ *$/ { inner = 0;next }
		!inner { name = $0;inner++;next }

		/^background/ {
			if((filter == 1 && luma($2) > 130) ||
			   (filter == 2 && luma($2) <= 130))
				next

			candidates[name] = 1
		}

		END {
			for(c in candidates) {
				if(!mruIndex[c])
					print(c)
			}

			for(i = 0;i < nmru;i++)
				if(candidates[mru[i]])
					print(mru[i])
		}
	' < "$0"
}


if [ -z "$1" ]; then
	if [ -t 0 ]; then
		echo "usage: $(basename "$0") [-v] [-h] <option>|<theme>"
		exit 255
	else
		apply_theme
		exit 0
	fi
fi

case "$1" in
	--dark|--light)
		filterFlag=$1
		shift
		;;
esac

case "$1" in
-h|--help)
		cat << "!"
usage: theme.sh [--light] | [--dark] <option> | <theme>

  If <theme> is provided it will immediately be set. Otherwise --dark or
  --light optionally act as filters on the supplied option. Theme history is
  stored in ~/.theme_history or ($XDG_CONFIG_HOME/.theme_history if set) by
  default and will be used for ordering the otherwise alphabetical theme list
  in the relevant options (-l/-i/-i2).

  E.G:
    'theme.sh --dark -i'

  will start an interactive selection of dark themes with the user's
  most recently selected themes at the bottom of the list.

  Theme definitions consistent with the internal format can also be piped
  directly into the script.

  E.G:

  # theme.sh < input

  Where input has the form:

      0: #4d4d4d
      1: #4d4d4d
      ...
      foreground: #dcdccc
      background: #3f3f3f
      cursor: #dcdccc

OPTIONS
  -l,--list                 Print all available themes.
  -i,--interactive          Start the interactive selection mode (requires fzf).
  -i2,--interactive2        Interactive mode #2. This shows the theme immediately
                            instead of showing it in the preview window. Useful
			    if your terminal does have TRUECOLOR support.
  -r,--random               Set a random theme and print its name to stdout.
  -a,--add <kitty config>   Annexes the given kitty config file.
  -p,--print-theme          Attempt to read the current theme from the terminal
                            and print it to stdout in a format consumable by theme.sh.
                            NOTE: not all terminals support this option,
		            do not rely on it in scripts.
  -v,--version              Print the version and exit.

SCRIPTING
  If used from within a script, you will probably want to set
  INHIBIT_THEME_HIST=1 to avoid mangling the user's theme history.
!
	;;
-p|--print-theme)
	print_current_theme
	;;
-i2|--interactive2)
	command -v fzf > /dev/null 2>&1 || { echo "ERROR: -i requires fzf" >&2; exit 1; }
	"$0" $filterFlag -l|fzf\
		--tac\
		--bind "enter:execute-silent($0 {})+accept"\
		--bind "ctrl-c:execute($0 -l|tail -n1|xargs $0)+abort"\
		--bind "esc:execute($0 {};echo {})+abort"\
		--exact\
		--no-sort\
		--preview "$0 --preview2 {}"
	;;
-r|--random)
	# Sort -R is not portable :/

	theme=$($0 $filterFlag -l|awk '{a[n++]=$0};END{srand();print(a[int(rand()*n)])}')
	$0 "$theme"
	echo "Theme: $theme"
	;;
-i|--interactive)
	command -v fzf > /dev/null 2>&1 || { echo "ERROR: -i requires fzf" >&2; exit 1; }
	if ! isColorTerm; then
		printf "WARNING: This does not appear to be a truecolor terminal, falling back to -i2
         (use -i2 explicitly to get rid of this message or set COLORTERM)\n\n" >&2
		"$0" $filterFlag -i2
	else
		"$0" $filterFlag -l|fzf\
			--tac\
			--exact\
			--bind "ctrl-c:abort"\
			--bind "esc:execute(echo {})+abort"\
			--bind "enter:execute-silent($0 {})+accept"\
			--no-sort\
			--preview "$0 --preview {}"
	fi
	;;
-l|--list)
	list
	;;
-a|--add)
	shift
	add "$@"
	;;
--preview2)
	preview2 "$2"
	;;
--preview)
	preview "$2"
	;;
-v|--version)
	echo "$VERSION (original source https://github.com/lemnos/theme.sh)"
	;;
*)
	set_current_theme "$1"
	;;
esac

exit $?

# Themes start here (avoid editing by hand)

3024
0: #090300
1: #db2d20
2: #01a252
3: #fded02
4: #01a0e4
5: #a16a94
6: #b5e4f4
7: #a5a2a2
8: #5c5855
9: #db2d20
10: #01a252
11: #fded02
12: #01a0e4
13: #a16a94
14: #b5e4f4
15: #f7f7f7
foreground: #a5a2a2
background: #090300
cursor: #a5a2a2

3024-day
0: #090300
1: #db2d20
2: #01a252
3: #fded02
4: #01a0e4
5: #a16a94
6: #b5e4f4
7: #a5a2a2
8: #5c5855
9: #e8bbd0
10: #3a3432
11: #4a4543
12: #807d7c
13: #d6d5d4
14: #cdab53
15: #f7f7f7
foreground: #4a4543
background: #f7f7f7
cursor: #4a4543

3024-night
0: #090300
1: #db2d20
2: #01a252
3: #fded02
4: #01a0e4
5: #a16a94
6: #b5e4f4
7: #a5a2a2
8: #5c5855
9: #e8bbd0
10: #3a3432
11: #4a4543
12: #807d7c
13: #d6d5d4
14: #cdab53
15: #f7f7f7
foreground: #a5a2a2
background: #090300
cursor: #a5a2a2

abyss
0: #040f18
1: #48697e
2: #10598b
3: #1f6ca1
4: #277bb1
5: #4595bd
6: #2592d3
7: #a0cce2
8: #708e9e
9: #48697e
10: #10598b
11: #1f6ca1
12: #277bb1
13: #4595bd
14: #2592d3
15: #a0cce2
foreground: #c0c7ca
background: #040f18
cursor: #10598b

aci
0: #363636
1: #ff0883
2: #83ff08
3: #ff8308
4: #0883ff
5: #8308ff
6: #08ff83
7: #b6b6b6
8: #424242
9: #ff1e8e
10: #8eff1e
11: #ff8e1e
12: #1e8eff
13: #8e1eff
14: #1eff8e
15: #c2c2c2
foreground: #b4e1fd
background: #0d1926
cursor: #b4e1fd

aco
0: #3f3f3f
1: #ff0883
2: #83ff08
3: #ff8308
4: #0883ff
5: #8308ff
6: #08ff83
7: #bebebe
8: #474747
9: #ff1e8e
10: #8eff1e
11: #ff8e1e
12: #1e8eff
13: #8e1eff
14: #1eff8e
15: #c4c4c4
foreground: #b4e1fd
background: #1f1305
cursor: #b4e1fd

adventuretime
0: #050404
1: #bd0013
2: #4ab118
3: #e7741e
4: #0f4ac6
5: #665993
6: #70a598
7: #f8dcc0
8: #4e7cbf
9: #fc5f5a
10: #9eff6e
11: #efc11a
12: #1997c6
13: #9b5953
14: #c8faf4
15: #f6f5fb
foreground: #f8dcc0
background: #1f1d45
cursor: #f8dcc0

afterglow
0: #151515
1: #a53c23
2: #7b9246
3: #d3a04d
4: #6c99bb
5: #9f4e85
6: #7dd6cf
7: #d0d0d0
8: #505050
9: #a53c23
10: #7b9246
11: #d3a04d
12: #547c99
13: #9f4e85
14: #7dd6cf
15: #f5f5f5
foreground: #d0d0d0
background: #222222
cursor: #d0d0d0

alien-blood
0: #112616
1: #7f2b27
2: #2f7e25
3: #717f24
4: #2f6a7f
5: #47587f
6: #327f77
7: #647d75
8: #3c4812
9: #e08009
10: #18e000
11: #bde000
12: #00aae0
13: #0058e0
14: #00e0c4
15: #73fa91
foreground: #637d75
background: #0f1610
cursor: #637d75

alucard
0: #000000
1: #ff5555
2: #fa0074
3: #7f0a1f
4: #3282ff
5: #1b3cff
6: #0037fc
7: #bbbbbb
8: #545454
9: #ff5454
10: #50fa7b
11: #f0fa8b
12: #1200f8
13: #ff78c5
14: #8ae9fc
15: #ffffff
foreground: #cef3ff
background: #222330
cursor: #ffffff

amora
0: #28222d
1: #ed3f7f
2: #a2baa8
3: #eacac0
4: #9985d1
5: #e68ac1
6: #aabae7
7: #dedbeb
8: #302838
9: #fb5c8e
10: #bfd1c3
11: #f0ddd8
12: #b4a4de
13: #edabd2
14: #c4d1f5
15: #edebf7
foreground: #dedbeb
background: #2a2331
cursor: #dedbeb

apathy
0: #031a16
1: #3e9688
2: #883e96
3: #3e4c96
4: #96883e
5: #4c963e
6: #963e4c
7: #81b5ac
8: #2b685e
9: #3e9688
10: #883e96
11: #3e4c96
12: #96883e
13: #4c963e
14: #963e4c
15: #d2e7e4
foreground: #81b5ac
background: #031a16
cursor: #81b5ac

apprentice
0: #262626
1: #5f8787
2: #87af87
3: #5f8787
4: #ffffaf
5: #87afd7
6: #5f875f
7: #bcbcbc
8: #6c6c6c
9: #5f8787
10: #87af87
11: #5f8787
12: #ffffaf
13: #87afd7
14: #5f875f
15: #ffffff
foreground: #bcbcbc
background: #262626
cursor: #bcbcbc

argonaut
0: #232323
1: #ff000f
2: #8ce10b
3: #ffb900
4: #008df8
5: #6d43a6
6: #00d8eb
7: #ffffff
8: #444444
9: #ff2740
10: #abe15b
11: #ffd242
12: #0092ff
13: #9a5feb
14: #67fff0
15: #ffffff
foreground: #fffaf4
background: #0e1019
cursor: #fffaf4

arthur
0: #3d352a
1: #cd5c5c
2: #86af80
3: #e8ae5b
4: #6495ed
5: #deb887
6: #b0c4de
7: #bbaa99
8: #554444
9: #cc5533
10: #88aa22
11: #ffa75d
12: #87ceeb
13: #996600
14: #b0c4de
15: #ddccbb
foreground: #ddeedd
background: #1c1c1c
cursor: #ddeedd

ashes
0: #1c2023
1: #c7ae95
2: #95c7ae
3: #aec795
4: #ae95c7
5: #c795ae
6: #95aec7
7: #c7ccd1
8: #747c84
9: #c7ae95
10: #95c7ae
11: #aec795
12: #ae95c7
13: #c795ae
14: #95aec7
15: #f3f4f5
foreground: #c7ccd1
background: #1c2023
cursor: #c7ccd1

atelier-cave
0: #19171c
1: #be4678
2: #2a9292
3: #a06e3b
4: #576ddb
5: #955ae7
6: #398bc6
7: #8b8792
8: #655f6d
9: #be4678
10: #2a9292
11: #a06e3b
12: #576ddb
13: #955ae7
14: #398bc6
15: #efecf4
foreground: #8b8792
background: #19171c
cursor: #8b8792

atelier-cave-light
0: #efecf4
1: #be4678
2: #2a9292
3: #a06e3b
4: #576ddb
5: #955ae7
6: #398bc6
7: #585260
8: #7e7887
9: #be4678
10: #2a9292
11: #a06e3b
12: #576ddb
13: #955ae7
14: #398bc6
15: #19171c
foreground: #585260
background: #efecf4
cursor: #585260

atelier-dune
0: #20201d
1: #d73737
2: #60ac39
3: #ae9513
4: #6684e1
5: #b854d4
6: #1fad83
7: #a6a28c
8: #7d7a68
9: #d73737
10: #60ac39
11: #ae9513
12: #6684e1
13: #b854d4
14: #1fad83
15: #fefbec
foreground: #a6a28c
background: #20201d
cursor: #a6a28c

atelier-dune-light
0: #fefbec
1: #d73737
2: #60ac39
3: #ae9513
4: #6684e1
5: #b854d4
6: #1fad83
7: #6e6b5e
8: #999580
9: #d73737
10: #60ac39
11: #ae9513
12: #6684e1
13: #b854d4
14: #1fad83
15: #20201d
foreground: #6e6b5e
background: #fefbec
cursor: #6e6b5e

atelier-estuary
0: #22221b
1: #ba6236
2: #7d9726
3: #a5980d
4: #36a166
5: #5f9182
6: #5b9d48
7: #929181
8: #6c6b5a
9: #ba6236
10: #7d9726
11: #a5980d
12: #36a166
13: #5f9182
14: #5b9d48
15: #f4f3ec
foreground: #929181
background: #22221b
cursor: #929181

atelier-estuary-light
0: #f4f3ec
1: #ba6236
2: #7d9726
3: #a5980d
4: #36a166
5: #5f9182
6: #5b9d48
7: #5f5e4e
8: #878573
9: #ba6236
10: #7d9726
11: #a5980d
12: #36a166
13: #5f9182
14: #5b9d48
15: #22221b
foreground: #5f5e4e
background: #f4f3ec
cursor: #5f5e4e

atelier-forest
0: #1b1918
1: #f22c40
2: #7b9726
3: #c38418
4: #407ee7
5: #6666ea
6: #3d97b8
7: #a8a19f
8: #766e6b
9: #f22c40
10: #7b9726
11: #c38418
12: #407ee7
13: #6666ea
14: #3d97b8
15: #f1efee
foreground: #a8a19f
background: #1b1918
cursor: #a8a19f

atelier-forest-light
0: #f1efee
1: #f22c40
2: #7b9726
3: #c38418
4: #407ee7
5: #6666ea
6: #3d97b8
7: #68615e
8: #9c9491
9: #f22c40
10: #7b9726
11: #c38418
12: #407ee7
13: #6666ea
14: #3d97b8
15: #1b1918
foreground: #68615e
background: #f1efee
cursor: #68615e

atelier-heath
0: #1b181b
1: #ca402b
2: #918b3b
3: #bb8a35
4: #516aec
5: #7b59c0
6: #159393
7: #ab9bab
8: #776977
9: #ca402b
10: #918b3b
11: #bb8a35
12: #516aec
13: #7b59c0
14: #159393
15: #f7f3f7
foreground: #ab9bab
background: #1b181b
cursor: #ab9bab

atelier-heath-light
0: #f7f3f7
1: #ca402b
2: #918b3b
3: #bb8a35
4: #516aec
5: #7b59c0
6: #159393
7: #695d69
8: #9e8f9e
9: #ca402b
10: #918b3b
11: #bb8a35
12: #516aec
13: #7b59c0
14: #159393
15: #1b181b
foreground: #695d69
background: #f7f3f7
cursor: #695d69

atelier-lakeside
0: #161b1d
1: #d22d72
2: #568c3b
3: #8a8a0f
4: #257fad
5: #6b6bb8
6: #2d8f6f
7: #7ea2b4
8: #5a7b8c
9: #d22d72
10: #568c3b
11: #8a8a0f
12: #257fad
13: #6b6bb8
14: #2d8f6f
15: #ebf8ff
foreground: #7ea2b4
background: #161b1d
cursor: #7ea2b4

atelier-lakeside-light
0: #ebf8ff
1: #d22d72
2: #568c3b
3: #8a8a0f
4: #257fad
5: #6b6bb8
6: #2d8f6f
7: #516d7b
8: #7195a8
9: #d22d72
10: #568c3b
11: #8a8a0f
12: #257fad
13: #6b6bb8
14: #2d8f6f
15: #161b1d
foreground: #516d7b
background: #ebf8ff
cursor: #516d7b

atelier-plateau
0: #1b1818
1: #ca4949
2: #4b8b8b
3: #a06e3b
4: #7272ca
5: #8464c4
6: #5485b6
7: #8a8585
8: #655d5d
9: #ca4949
10: #4b8b8b
11: #a06e3b
12: #7272ca
13: #8464c4
14: #5485b6
15: #f4ecec
foreground: #8a8585
background: #1b1818
cursor: #8a8585

atelier-plateau-light
0: #f4ecec
1: #ca4949
2: #4b8b8b
3: #a06e3b
4: #7272ca
5: #8464c4
6: #5485b6
7: #585050
8: #7e7777
9: #ca4949
10: #4b8b8b
11: #a06e3b
12: #7272ca
13: #8464c4
14: #5485b6
15: #1b1818
foreground: #585050
background: #f4ecec
cursor: #585050

atelier-savanna
0: #171c19
1: #b16139
2: #489963
3: #a07e3b
4: #478c90
5: #55859b
6: #1c9aa0
7: #87928a
8: #5f6d64
9: #b16139
10: #489963
11: #a07e3b
12: #478c90
13: #55859b
14: #1c9aa0
15: #ecf4ee
foreground: #87928a
background: #171c19
cursor: #87928a

atelier-savanna-light
0: #ecf4ee
1: #b16139
2: #489963
3: #a07e3b
4: #478c90
5: #55859b
6: #1c9aa0
7: #526057
8: #78877d
9: #b16139
10: #489963
11: #a07e3b
12: #478c90
13: #55859b
14: #1c9aa0
15: #171c19
foreground: #526057
background: #ecf4ee
cursor: #526057

atelier-seaside
0: #131513
1: #e6193c
2: #29a329
3: #98981b
4: #3d62f5
5: #ad2bee
6: #1999b3
7: #8ca68c
8: #687d68
9: #e6193c
10: #29a329
11: #98981b
12: #3d62f5
13: #ad2bee
14: #1999b3
15: #f4fbf4
foreground: #8ca68c
background: #131513
cursor: #8ca68c

atelier-seaside-light
0: #f4fbf4
1: #e6193c
2: #29a329
3: #98981b
4: #3d62f5
5: #ad2bee
6: #1999b3
7: #5e6e5e
8: #809980
9: #e6193c
10: #29a329
11: #98981b
12: #3d62f5
13: #ad2bee
14: #1999b3
15: #131513
foreground: #5e6e5e
background: #f4fbf4
cursor: #5e6e5e

atelier-sulphurpool
0: #202746
1: #c94922
2: #ac9739
3: #c08b30
4: #3d8fd1
5: #6679cc
6: #22a2c9
7: #979db4
8: #6b7394
9: #c94922
10: #ac9739
11: #c08b30
12: #3d8fd1
13: #6679cc
14: #22a2c9
15: #f5f7ff
foreground: #979db4
background: #202746
cursor: #979db4

atelier-sulphurpool-light
0: #f5f7ff
1: #c94922
2: #ac9739
3: #c08b30
4: #3d8fd1
5: #6679cc
6: #22a2c9
7: #5e6687
8: #898ea4
9: #c94922
10: #ac9739
11: #c08b30
12: #3d8fd1
13: #6679cc
14: #22a2c9
15: #202746
foreground: #5e6687
background: #f5f7ff
cursor: #5e6687

atlas
0: #002635
1: #ff5a67
2: #7fc06e
3: #ffcc1b
4: #5dd7b9
5: #9a70a4
6: #14747e
7: #a1a19a
8: #6c8b91
9: #ff5a67
10: #7fc06e
11: #ffcc1b
12: #5dd7b9
13: #9a70a4
14: #14747e
15: #fafaf8
foreground: #a1a19a
background: #002635
cursor: #a1a19a

atom
0: #000000
1: #fd5ff1
2: #87c38a
3: #ffd7b1
4: #85befd
5: #b9b6fc
6: #85befd
7: #e0e0e0
8: #000000
9: #fd5ff1
10: #94fa36
11: #f5ffa8
12: #96cbfe
13: #b9b6fc
14: #85befd
15: #e0e0e0
foreground: #c5c8c6
background: #161719
cursor: #c5c8c6

atom-one-light
0: #000000
1: #de3d35
2: #3e953a
3: #d2b67b
4: #2f5af3
5: #950095
6: #3e953a
7: #bbbbbb
8: #000000
9: #de3d35
10: #3e953a
11: #d2b67b
12: #2f5af3
13: #a00095
14: #3e953a
15: #ffffff
foreground: #2a2b33
background: #f8f8f8
cursor: #bbbbbb

ayu
0: #000000
1: #ff3333
2: #b8cc52
3: #e6c446
4: #36a3d9
5: #f07078
6: #95e5cb
7: #ffffff
8: #323232
9: #ff6565
10: #e9fe83
11: #fff778
12: #68d4ff
13: #ffa3aa
14: #c7fffc
15: #ffffff
foreground: #e5e1cf
background: #0e1419
cursor: #f19618

ayu-light
0: #000000
1: #ff3333
2: #86b200
3: #f19618
4: #41a6d9
5: #f07078
6: #4cbe99
7: #ffffff
8: #323232
9: #ff6565
10: #b8e532
11: #ffc849
12: #73d7ff
13: #ffa3aa
14: #7ff0cb
15: #ffffff
foreground: #5b6673
background: #fafafa
cursor: #ff6900

ayu-mirage
0: #191e2a
1: #ed8274
2: #a6cc70
3: #fad07b
4: #6dcbfa
5: #cfbafa
6: #90e1c6
7: #c7c7c7
8: #686868
9: #f28779
10: #bae67e
11: #ffd580
12: #73d0ff
13: #d4bfff
14: #95e6cb
15: #ffffff
foreground: #d9d7ce
background: #212733
cursor: #ffcc66

ayu-mirage-simple-cursor
0: #191e2a
1: #ed8274
2: #a6cc70
3: #fad07b
4: #6dcbfa
5: #cfbafa
6: #90e1c6
7: #c7c7c7
8: #686868
9: #f28779
10: #bae67e
11: #ffd580
12: #73d0ff
13: #d4bfff
14: #95e6cb
15: #ffffff
foreground: #d9d7ce
background: #212733
cursor: #d9d7ce

azu
0: #000000
1: #ac6d74
2: #74ac6d
3: #aca46d
4: #6d74ac
5: #a46dac
6: #6daca4
7: #e6e6e6
8: #262626
9: #d6b8bc
10: #bcd6b8
11: #d6d3b8
12: #b8bcd6
13: #d3b8d6
14: #b8d6d3
15: #ffffff
foreground: #d9e6f2
background: #09111a
cursor: #d9e6f2

batman
0: #1b1d1e
1: #e6db43
2: #c8be46
3: #f3fd21
4: #737074
5: #737271
6: #615f5e
7: #c5c5be
8: #505354
9: #fff68d
10: #fff27c
11: #feed6c
12: #909495
13: #9a999d
14: #a2a2a5
15: #dadad5
foreground: #6e6e6e
background: #1b1d1e
cursor: #fcee0b

belafonte-day
0: #20111b
1: #be100e
2: #858162
3: #eaa549
4: #426a79
5: #97522c
6: #989a9c
7: #968c83
8: #5e5252
9: #be100e
10: #858162
11: #eaa549
12: #426a79
13: #97522c
14: #989a9c
15: #d5ccba
foreground: #45373c
background: #d5ccba
cursor: #45373c

belafonte-night
0: #20111b
1: #be100e
2: #858162
3: #eaa549
4: #426a79
5: #97522c
6: #989a9c
7: #968c83
8: #5e5252
9: #be100e
10: #858162
11: #eaa549
12: #426a79
13: #97522c
14: #989a9c
15: #d5ccba
foreground: #968c83
background: #20111b
cursor: #968c83

bespin
0: #28211c
1: #cf6a4c
2: #54be0d
3: #f9ee98
4: #5ea6ea
5: #9b859d
6: #afc4db
7: #8a8986
8: #666666
9: #cf6a4c
10: #54be0d
11: #f9ee98
12: #5ea6ea
13: #9b859d
14: #afc4db
15: #baae9e
foreground: #8a8986
background: #28211c
cursor: #8a8986

bim
0: #2c2423
1: #f557a0
2: #a9ee55
3: #f5a255
4: #5ea2ec
5: #a957ec
6: #5eeea0
7: #918988
8: #918988
9: #f579b2
10: #bbee78
11: #f5b378
12: #81b3ec
13: #bb79ec
14: #81eeb2
15: #f5eeec
foreground: #a9bed8
background: #012849
cursor: #a9bed8

birds-of-paradise
0: #573d26
1: #be2d26
2: #6ba18a
3: #e99d2a
4: #5a86ad
5: #ac80a6
6: #74a6ad
7: #e0dbb7
8: #9b6c4a
9: #e84627
10: #95d8ba
11: #d0d150
12: #b8d3ed
13: #d19ecb
14: #93cfd7
15: #fff9d5
foreground: #e0dbb7
background: #2a1f1d
cursor: #e0dbb7

black-metal
0: #000000
1: #5f8787
2: #dd9999
3: #a06666
4: #888888
5: #999999
6: #aaaaaa
7: #c1c1c1
8: #333333
9: #5f8787
10: #dd9999
11: #a06666
12: #888888
13: #999999
14: #aaaaaa
15: #c1c1c1
foreground: #c1c1c1
background: #000000
cursor: #c1c1c1

black-metal-bathory
0: #000000
1: #5f8787
2: #fbcb97
3: #e78a53
4: #888888
5: #999999
6: #aaaaaa
7: #c1c1c1
8: #333333
9: #5f8787
10: #fbcb97
11: #e78a53
12: #888888
13: #999999
14: #aaaaaa
15: #c1c1c1
foreground: #c1c1c1
background: #000000
cursor: #c1c1c1

black-metal-burzum
0: #000000
1: #5f8787
2: #ddeecc
3: #99bbaa
4: #888888
5: #999999
6: #aaaaaa
7: #c1c1c1
8: #333333
9: #5f8787
10: #ddeecc
11: #99bbaa
12: #888888
13: #999999
14: #aaaaaa
15: #c1c1c1
foreground: #c1c1c1
background: #000000
cursor: #c1c1c1

black-metal-dark-funeral
0: #000000
1: #5f8787
2: #d0dfee
3: #5f81a5
4: #888888
5: #999999
6: #aaaaaa
7: #c1c1c1
8: #333333
9: #5f8787
10: #d0dfee
11: #5f81a5
12: #888888
13: #999999
14: #aaaaaa
15: #c1c1c1
foreground: #c1c1c1
background: #000000
cursor: #c1c1c1

black-metal-gorgoroth
0: #000000
1: #5f8787
2: #9b8d7f
3: #8c7f70
4: #888888
5: #999999
6: #aaaaaa
7: #c1c1c1
8: #333333
9: #5f8787
10: #9b8d7f
11: #8c7f70
12: #888888
13: #999999
14: #aaaaaa
15: #c1c1c1
foreground: #c1c1c1
background: #000000
cursor: #c1c1c1

black-metal-immortal
0: #000000
1: #5f8787
2: #7799bb
3: #556677
4: #888888
5: #999999
6: #aaaaaa
7: #c1c1c1
8: #333333
9: #5f8787
10: #7799bb
11: #556677
12: #888888
13: #999999
14: #aaaaaa
15: #c1c1c1
foreground: #c1c1c1
background: #000000
cursor: #c1c1c1

black-metal-khold
0: #000000
1: #5f8787
2: #eceee3
3: #974b46
4: #888888
5: #999999
6: #aaaaaa
7: #c1c1c1
8: #333333
9: #5f8787
10: #eceee3
11: #974b46
12: #888888
13: #999999
14: #aaaaaa
15: #c1c1c1
foreground: #c1c1c1
background: #000000
cursor: #c1c1c1

black-metal-marduk
0: #000000
1: #5f8787
2: #a5aaa7
3: #626b67
4: #888888
5: #999999
6: #aaaaaa
7: #c1c1c1
8: #333333
9: #5f8787
10: #a5aaa7
11: #626b67
12: #888888
13: #999999
14: #aaaaaa
15: #c1c1c1
foreground: #c1c1c1
background: #000000
cursor: #c1c1c1

black-metal-mayhem
0: #000000
1: #5f8787
2: #f3ecd4
3: #eecc6c
4: #888888
5: #999999
6: #aaaaaa
7: #c1c1c1
8: #333333
9: #5f8787
10: #f3ecd4
11: #eecc6c
12: #888888
13: #999999
14: #aaaaaa
15: #c1c1c1
foreground: #c1c1c1
background: #000000
cursor: #c1c1c1

black-metal-nile
0: #000000
1: #5f8787
2: #aa9988
3: #777755
4: #888888
5: #999999
6: #aaaaaa
7: #c1c1c1
8: #333333
9: #5f8787
10: #aa9988
11: #777755
12: #888888
13: #999999
14: #aaaaaa
15: #c1c1c1
foreground: #c1c1c1
background: #000000
cursor: #c1c1c1

black-metal-venom
0: #000000
1: #5f8787
2: #f8f7f2
3: #79241f
4: #888888
5: #999999
6: #aaaaaa
7: #c1c1c1
8: #333333
9: #5f8787
10: #f8f7f2
11: #79241f
12: #888888
13: #999999
14: #aaaaaa
15: #c1c1c1
foreground: #c1c1c1
background: #000000
cursor: #c1c1c1

blazer
0: #000000
1: #b87a7a
2: #7ab87a
3: #b8b87a
4: #7a7ab8
5: #b87ab8
6: #7ab8b8
7: #d9d9d9
8: #262626
9: #dbbdbd
10: #bddbbd
11: #dbdbbd
12: #bdbddb
13: #dbbddb
14: #bddbdb
15: #ffffff
foreground: #d9e6f2
background: #0d1926
cursor: #d9e6f2

borland
0: #4f4f4f
1: #ff6c60
2: #a8ff60
3: #ffffb6
4: #96cbfe
5: #ff73fd
6: #c6c5fe
7: #eeeeee
8: #7c7c7c
9: #ffb6b0
10: #ceffac
11: #ffffcc
12: #b5dcff
13: #ff9cfe
14: #dfdffe
15: #ffffff
foreground: #ffff4e
background: #0000a4
cursor: #ffff4e

brewer
0: #0c0d0e
1: #e31a1c
2: #31a354
3: #dca060
4: #3182bd
5: #756bb1
6: #80b1d3
7: #b7b8b9
8: #737475
9: #e31a1c
10: #31a354
11: #dca060
12: #3182bd
13: #756bb1
14: #80b1d3
15: #fcfdfe
foreground: #b7b8b9
background: #0c0d0e
cursor: #b7b8b9

bright
0: #000000
1: #fb0120
2: #a1c659
3: #fda331
4: #6fb3d2
5: #d381c3
6: #76c7b7
7: #e0e0e0
8: #b0b0b0
9: #fb0120
10: #a1c659
11: #fda331
12: #6fb3d2
13: #d381c3
14: #76c7b7
15: #ffffff
foreground: #e0e0e0
background: #000000
cursor: #e0e0e0

bright-lights
0: #191919
1: #ff355b
2: #b6e875
3: #ffc150
4: #75d3ff
5: #b975e6
6: #6cbeb5
7: #c1c8d6
8: #191919
9: #ff355b
10: #b6e875
11: #ffc150
12: #75d4ff
13: #b975e6
14: #6cbeb5
15: #c1c8d6
foreground: #b2c8d6
background: #191919
cursor: #f34a00

broadcast
0: #000000
1: #da4939
2: #519f50
3: #ffd24a
4: #6d9cbe
5: #d0d0ff
6: #6e9cbe
7: #ffffff
8: #323232
9: #ff7b6b
10: #83d182
11: #ffff7c
12: #9fcef0
13: #ffffff
14: #a0cef0
15: #ffffff
foreground: #e6e1dc
background: #2b2b2b
cursor: #e6e1dc

brogrammer
0: #1f1f1f
1: #d6dbe5
2: #f3bd09
3: #1dd361
4: #5350b9
5: #0f7ddb
6: #1081d6
7: #4e5ab7
8: #ecba0f
9: #d6dbe5
10: #f3bd09
11: #1dd361
12: #5350b9
13: #0f7ddb
14: #1081d6
15: #d6dbe5
foreground: #4e5ab7
background: #1f1f1f
cursor: #4e5ab7

brushtrees
0: #e3efef
1: #b38686
2: #87b386
3: #aab386
4: #868cb3
5: #b386b2
6: #86b3b3
7: #6d828e
8: #98afb5
9: #b38686
10: #87b386
11: #aab386
12: #868cb3
13: #b386b2
14: #86b3b3
15: #485867
foreground: #6d828e
background: #e3efef
cursor: #6d828e

brushtrees-dark
0: #485867
1: #b38686
2: #87b386
3: #aab386
4: #868cb3
5: #b386b2
6: #86b3b3
7: #b0c5c8
8: #8299a1
9: #b38686
10: #87b386
11: #aab386
12: #868cb3
13: #b386b2
14: #86b3b3
15: #e3efef
foreground: #b0c5c8
background: #485867
cursor: #b0c5c8

c64
0: #090300
1: #883932
2: #55a049
3: #bfce72
4: #40318d
5: #8b3f96
6: #67b6bd
7: #ffffff
8: #000000
9: #883932
10: #55a049
11: #bfce72
12: #40318d
13: #8b3f96
14: #67b6bd
15: #f7f7f7
foreground: #7869c4
background: #40318d
cursor: #7869c4

cai
0: #000000
1: #ca274d
2: #4dca27
3: #caa427
4: #274dca
5: #a427ca
6: #27caa4
7: #808080
8: #808080
9: #e98da3
10: #a3e98d
11: #e9d48d
12: #8da3e9
13: #d48de9
14: #8de9d4
15: #ffffff
foreground: #d9e6f2
background: #09111a
cursor: #d9e6f2

chalk
0: #151515
1: #fb9fb1
2: #acc267
3: #ddb26f
4: #6fc2ef
5: #e1a3ee
6: #12cfc0
7: #d0d0d0
8: #505050
9: #fb9fb1
10: #acc267
11: #ddb26f
12: #6fc2ef
13: #e1a3ee
14: #12cfc0
15: #f5f5f5
foreground: #d0d0d0
background: #151515
cursor: #d0d0d0

chalkboard
0: #000000
1: #c37372
2: #72c373
3: #c2c372
4: #7372c3
5: #c372c2
6: #72c2c3
7: #d9d9d9
8: #323232
9: #dbaaaa
10: #aadbaa
11: #dadbaa
12: #aaaadb
13: #dbaada
14: #aadadb
15: #ffffff
foreground: #d9e6f2
background: #29262f
cursor: #d9e6f2

challenger-deep
0: #565575
1: #ff8080
2: #95ffa4
3: #ffe9aa
4: #91ddff
5: #c991e1
6: #aaffe4
7: #cbe3e7
8: #100e23
9: #ff5458
10: #62d196
11: #ffb378
12: #65b2ff
13: #906cff
14: #63f2f1
15: #a6b3cc
foreground: #cbe3e7
background: #1e1c31
cursor: #cbe3e7

ciapre
0: #181818
1: #810009
2: #48513b
3: #cc8b3f
4: #576d8c
5: #724d7c
6: #5c4f4b
7: #aea47f
8: #555555
9: #ac3835
10: #a6a75d
11: #dcdf7c
12: #3097c6
13: #d33061
14: #f3dbb2
15: #f4f4f4
foreground: #aea47a
background: #191c27
cursor: #aea47a

circus
0: #191919
1: #dc657d
2: #84b97c
3: #c3ba63
4: #639ee4
5: #b888e2
6: #4bb1a7
7: #a7a7a7
8: #5f5a60
9: #dc657d
10: #84b97c
11: #c3ba63
12: #639ee4
13: #b888e2
14: #4bb1a7
15: #ffffff
foreground: #a7a7a7
background: #191919
cursor: #a7a7a7

classic-dark
0: #151515
1: #ac4142
2: #90a959
3: #f4bf75
4: #6a9fb5
5: #aa759f
6: #75b5aa
7: #d0d0d0
8: #505050
9: #ac4142
10: #90a959
11: #f4bf75
12: #6a9fb5
13: #aa759f
14: #75b5aa
15: #f5f5f5
foreground: #d0d0d0
background: #151515
cursor: #d0d0d0

classic-light
0: #f5f5f5
1: #ac4142
2: #90a959
3: #f4bf75
4: #6a9fb5
5: #aa759f
6: #75b5aa
7: #303030
8: #b0b0b0
9: #ac4142
10: #90a959
11: #f4bf75
12: #6a9fb5
13: #aa759f
14: #75b5aa
15: #151515
foreground: #303030
background: #f5f5f5
cursor: #303030

clone-of-ubuntu
0: #2e3436
1: #cc0000
2: #4e9a06
3: #c4a000
4: #3465a4
5: #75507b
6: #06989a
7: #d3d7cf
8: #555753
9: #ef2929
10: #8ae234
11: #fce94f
12: #729fcf
13: #ad7fa8
14: #34e2e2
15: #eeeeec
foreground: #ffffff
background: #300a24
cursor: #ffffff

clrs
0: #000000
1: #f8282a
2: #328a5d
3: #fa701d
4: #135cd0
5: #9f00bd
6: #33c3c1
7: #b3b3b3
8: #555753
9: #fb0416
10: #2cc631
11: #fdd727
12: #1670ff
13: #e900b0
14: #3ad5ce
15: #eeeeec
foreground: #262626
background: #ffffff
cursor: #262626

cobalt-neon
0: #142631
1: #ff2320
2: #3ba5ff
3: #e9e75c
4: #8ff586
5: #781aa0
6: #8ff586
7: #ba46b2
8: #fff688
9: #d4312e
10: #8ff586
11: #e9f06d
12: #3c7dd2
13: #8230a7
14: #6cbc67
15: #8ff586
foreground: #8ff586
background: #142838
cursor: #8ff586

cobalt2
0: #000000
1: #ff0000
2: #38de21
3: #ffe50a
4: #1460d2
5: #ff005d
6: #00bbbb
7: #bbbbbb
8: #555555
9: #f40e17
10: #3bd01d
11: #edc809
12: #5555ff
13: #ff55ff
14: #6ae3fa
15: #ffffff
foreground: #ffffff
background: #132738
cursor: #ffffff

codeschool
0: #232c31
1: #2a5491
2: #237986
3: #a03b1e
4: #484d79
5: #c59820
6: #b02f30
7: #9ea7a6
8: #3f4944
9: #2a5491
10: #237986
11: #a03b1e
12: #484d79
13: #c59820
14: #b02f30
15: #b5d8f6
foreground: #9ea7a6
background: #232c31
cursor: #9ea7a6

corvine
0: #3a3a3a
1: #d78787
2: #87af5f
3: #d7d7af
4: #87afd7
5: #afafd7
6: #87d7d7
7: #c6c6c6
8: #626262
9: #ffafaf
10: #afd787
11: #d7d787
12: #87d7ff
13: #d7afd7
14: #5fd7d7
15: #eeeeee
foreground: #c6c6c6
background: #262626
cursor: #c6c6c6

crayon-pony-fish
0: #2b1b1d
1: #91002b
2: #579524
3: #ab311b
4: #8c87b0
5: #692f50
6: #e8a866
7: #68525a
8: #3d2b2e
9: #c5255d
10: #8dff57
11: #c8381d
12: #cfc9ff
13: #fc6cba
14: #ffceaf
15: #b0949d
foreground: #68525a
background: #150707
cursor: #68525a

cupcake
0: #fbf1f2
1: #d57e85
2: #a3b367
3: #dcb16c
4: #7297b9
5: #bb99b4
6: #69a9a7
7: #8b8198
8: #bfb9c6
9: #d57e85
10: #a3b367
11: #dcb16c
12: #7297b9
13: #bb99b4
14: #69a9a7
15: #585062
foreground: #8b8198
background: #fbf1f2
cursor: #8b8198

cupertino
0: #ffffff
1: #c41a15
2: #007400
3: #826b28
4: #0000ff
5: #a90d91
6: #318495
7: #404040
8: #808080
9: #c41a15
10: #007400
11: #826b28
12: #0000ff
13: #a90d91
14: #318495
15: #5e5e5e
foreground: #404040
background: #ffffff
cursor: #404040

danqing
0: #2d302f
1: #f9906f
2: #8ab361
3: #f0c239
4: #b0a4e3
5: #cca4e3
6: #30dff3
7: #e0f0ef
8: #9da8a3
9: #f9906f
10: #8ab361
11: #f0c239
12: #b0a4e3
13: #cca4e3
14: #30dff3
15: #fcfefd
foreground: #e0f0ef
background: #2d302f
cursor: #e0f0ef

darcula
0: #2b2b2b
1: #4eade5
2: #6a8759
3: #bbb529
4: #9876aa
5: #cc7832
6: #629755
7: #a9b7c6
8: #606366
9: #4eade5
10: #6a8759
11: #bbb529
12: #9876aa
13: #cc7832
14: #629755
15: #ffffff
foreground: #a9b7c6
background: #2b2b2b
cursor: #a9b7c6

dark-pastel
0: #000000
1: #ff5555
2: #55ff55
3: #ffff55
4: #5555ff
5: #ff55ff
6: #55ffff
7: #bbbbbb
8: #555555
9: #ff5555
10: #55ff55
11: #ffff55
12: #5555ff
13: #ff55ff
14: #55ffff
15: #ffffff
foreground: #ffffff
background: #000000
cursor: #ffffff

darkmoss
0: #171e1f
1: #ff4658
2: #499180
3: #fdb11f
4: #498091
5: #9bc0c8
6: #66d9ef
7: #c7c7a5
8: #555e5f
9: #ff4658
10: #499180
11: #fdb11f
12: #498091
13: #9bc0c8
14: #66d9ef
15: #e1eaef
foreground: #c7c7a5
background: #171e1f
cursor: #c7c7a5

darkside
0: #000000
1: #e8341c
2: #68c256
3: #f2d42c
4: #1c98e8
5: #8e69c9
6: #1c98e8
7: #bababa
8: #000000
9: #e05a4f
10: #77b869
11: #efd64b
12: #387cd3
13: #957bbe
14: #3d97e2
15: #bababa
foreground: #bababa
background: #222324
cursor: #bababa

darktooth
0: #1d2021
1: #fb543f
2: #95c085
3: #fac03b
4: #0d6678
5: #8f4673
6: #8ba59b
7: #a89984
8: #665c54
9: #fb543f
10: #95c085
11: #fac03b
12: #0d6678
13: #8f4673
14: #8ba59b
15: #fdf4c1
foreground: #a89984
background: #1d2021
cursor: #a89984

darkviolet
0: #000000
1: #a82ee6
2: #4595e6
3: #f29df2
4: #4136d9
5: #7e5ce6
6: #40dfff
7: #b08ae6
8: #593380
9: #a82ee6
10: #4595e6
11: #f29df2
12: #4136d9
13: #7e5ce6
14: #40dfff
15: #a366ff
foreground: #b08ae6
background: #000000
cursor: #b08ae6

decaf
0: #2d2d2d
1: #ff7f7b
2: #beda78
3: #ffd67c
4: #90bee1
5: #efb3f7
6: #bed6ff
7: #cccccc
8: #777777
9: #ff7f7b
10: #beda78
11: #ffd67c
12: #90bee1
13: #efb3f7
14: #bed6ff
15: #ffffff
foreground: #cccccc
background: #2d2d2d
cursor: #cccccc

default-dark
0: #181818
1: #ab4642
2: #a1b56c
3: #f7ca88
4: #7cafc2
5: #ba8baf
6: #86c1b9
7: #d8d8d8
8: #585858
9: #ab4642
10: #a1b56c
11: #f7ca88
12: #7cafc2
13: #ba8baf
14: #86c1b9
15: #f8f8f8
foreground: #d8d8d8
background: #181818
cursor: #d8d8d8

default-light
0: #f8f8f8
1: #ab4642
2: #a1b56c
3: #f7ca88
4: #7cafc2
5: #ba8baf
6: #86c1b9
7: #383838
8: #b8b8b8
9: #ab4642
10: #a1b56c
11: #f7ca88
12: #7cafc2
13: #ba8baf
14: #86c1b9
15: #181818
foreground: #383838
background: #f8f8f8
cursor: #383838

desert
0: #4d4d4d
1: #ff2b2b
2: #98fb98
3: #f0e68c
4: #cd853f
5: #ffdead
6: #ffa0a0
7: #f5deb3
8: #555555
9: #ff5555
10: #55ff55
11: #ffff55
12: #87ceff
13: #ff55ff
14: #ffd700
15: #ffffff
foreground: #ffffff
background: #333333
cursor: #ffffff

desert-night
0: #473f31
1: #e56b55
2: #99b05f
3: #e18245
4: #949fb4
5: #d261a5
6: #bfab36
7: #87765d
8: #473f31
9: #e56b55
10: #99b05f
11: #e5a440
12: #949fb4
13: #d261a5
14: #bfab36
15: #87765d
foreground: #d4b07b
background: #24221c
cursor: #d4b07b

dimmed-monokai
0: #3a3d43
1: #be3f48
2: #879a3b
3: #c5a635
4: #4f76a1
5: #855c8d
6: #578fa4
7: #b9bcba
8: #888987
9: #fb001f
10: #0f722f
11: #c47033
12: #186de3
13: #fb0067
14: #2e706d
15: #fdffb9
foreground: #b9bcba
background: #1f1f1f
cursor: #b9bcba

dirtysea
0: #e0e0e0
1: #840000
2: #730073
3: #755b00
4: #007300
5: #000090
6: #755b00
7: #000000
8: #707070
9: #840000
10: #730073
11: #755b00
12: #007300
13: #000090
14: #755b00
15: #c4d9c4
foreground: #000000
background: #e0e0e0
cursor: #000000

dot-gov
0: #181818
1: #bf081d
2: #3d9751
3: #f6bb33
4: #16b1df
5: #772fb0
6: #8bd1ed
7: #ffffff
8: #181818
9: #bf081d
10: #3d9751
11: #f6bb33
12: #16b1df
13: #772fb0
14: #8bd1ed
15: #ffffff
foreground: #eaeaea
background: #252b35
cursor: #d9002f

dracula
0: #282936
1: #ea51b2
2: #ebff87
3: #00f769
4: #62d6e8
5: #b45bcf
6: #a1efe4
7: #e9e9f4
8: #626483
9: #ea51b2
10: #ebff87
11: #00f769
12: #62d6e8
13: #b45bcf
14: #a1efe4
15: #f7f7fb
foreground: #e9e9f4
background: #282936
cursor: #e9e9f4

dumbledore
0: #2b283d
1: #ae0000
2: #3e7c54
3: #f0c75e
4: #415baf
5: #9445ae
6: #008aff
7: #850000
8: #413e53
9: #d3a624
10: #aaaaaa
11: #716254
12: #946a2c
13: #b294ba
14: #25de50
15: #c9c9c9
foreground: #c4c8c5
background: #422553
cursor: #c4c8c5

duotone-dark
0: #1f1c27
1: #d8393d
2: #2dcc72
3: #d8b76e
4: #ffc183
5: #dd8d40
6: #2388ff
7: #b6a0ff
8: #353146
9: #d8393d
10: #2dcc72
11: #d8b76e
12: #ffc183
13: #dd8d40
14: #2388ff
15: #e9e4ff
foreground: #b6a0ff
background: #1f1c27
cursor: #ff9738

e-n-c-o-m
0: #000000
1: #9f0000
2: #008b00
3: #ffcf00
4: #0081ff
5: #bc00ca
6: #008b8b
7: #bbbbbb
8: #545454
9: #ff0000
10: #00ee00
11: #ffff00
12: #0000ff
13: #ff00ff
14: #00cdcd
15: #ffffff
foreground: #00a595
background: #000000
cursor: #bbbbbb

earthsong
0: #121418
1: #c94234
2: #85c54c
3: #f5ae2e
4: #1398b9
5: #d0633d
6: #509552
7: #e5c6aa
8: #675f54
9: #ff645a
10: #98e036
11: #e0d561
12: #5fdaff
13: #ff9269
14: #84f088
15: #f6f7ec
foreground: #e5c7a9
background: #292520
cursor: #e5c7a9

edge-dark
0: #262729
1: #e77171
2: #a1bf78
3: #dbb774
4: #73b3e7
5: #d390e7
6: #5ebaa5
7: #b7bec9
8: #3e4249
9: #e77171
10: #a1bf78
11: #dbb774
12: #73b3e7
13: #d390e7
14: #5ebaa5
15: #3e4249
foreground: #b7bec9
background: #262729
cursor: #b7bec9

edge-light
0: #fafafa
1: #db7070
2: #7c9f4b
3: #d69822
4: #6587bf
5: #b870ce
6: #509c93
7: #5e646f
8: #5e646f
9: #db7070
10: #7c9f4b
11: #d69822
12: #6587bf
13: #b870ce
14: #509c93
15: #5e646f
foreground: #5e646f
background: #fafafa
cursor: #5e646f

eighties
0: #2d2d2d
1: #f2777a
2: #99cc99
3: #ffcc66
4: #6699cc
5: #cc99cc
6: #66cccc
7: #d3d0c8
8: #747369
9: #f2777a
10: #99cc99
11: #ffcc66
12: #6699cc
13: #cc99cc
14: #66cccc
15: #f2f0ec
foreground: #d3d0c8
background: #2d2d2d
cursor: #d3d0c8

elemental
0: #3c3c30
1: #98290f
2: #479a43
3: #7f7111
4: #497f7d
5: #7f4e2f
6: #387f58
7: #807974
8: #555445
9: #e0502a
10: #61e070
11: #d69927
12: #79d9d9
13: #cd7c54
14: #59d599
15: #fff1e9
foreground: #807a74
background: #22211d
cursor: #807a74

elementary
0: #303030
1: #e1321a
2: #6ab017
3: #ffc005
4: #004f9e
5: #ec0048
6: #2aa7e7
7: #f2f2f2
8: #5d5d5d
9: #ff361e
10: #7bc91f
11: #ffd00a
12: #0071ff
13: #ff1d62
14: #4bb8fd
15: #a020f0
foreground: #f2f2f2
background: #101010
cursor: #f2f2f2

elic
0: #303030
1: #e1321a
2: #6ab017
3: #ffc005
4: #729fcf
5: #ec0048
6: #f2f2f2
7: #2aa7e7
8: #5d5d5d
9: #ff361e
10: #7bc91f
11: #ffd00a
12: #0071ff
13: #ff1d62
14: #4bb8fd
15: #a020f0
foreground: #f2f2f2
background: #4a453e
cursor: #f2f2f2

elio
0: #303030
1: #e1321a
2: #6ab017
3: #ffc005
4: #729fcf
5: #ec0048
6: #2aa7e7
7: #f2f2f2
8: #5d5d5d
9: #ff361e
10: #7bc91f
11: #ffd00a
12: #0071ff
13: #ff1d62
14: #4bb8fd
15: #a020f0
foreground: #f2f2f2
background: #041a3b
cursor: #f2f2f2

embark
0: #585273
1: #f48fb1
2: #a1efd3
3: #ffe6b3
4: #91ddff
5: #d4bfff
6: #87dfeb
7: #cbe3e7
8: #585273
9: #f02e6e
10: #62d196
11: #f2b482
12: #65b2ff
13: #a37acc
14: #63f2f1
15: #8a889d
foreground: #cbe3e7
background: #1e1c31
cursor: #cbe3e7

embers
0: #16130f
1: #826d57
2: #57826d
3: #6d8257
4: #6d5782
5: #82576d
6: #576d82
7: #a39a90
8: #5a5047
9: #826d57
10: #57826d
11: #6d8257
12: #6d5782
13: #82576d
14: #576d82
15: #dbd6d1
foreground: #a39a90
background: #16130f
cursor: #a39a90

equilibrium-dark
0: #0c1118
1: #f04339
2: #7f8b00
3: #bb8801
4: #008dd1
5: #6a7fd2
6: #00948b
7: #afaba2
8: #7b776e
9: #f04339
10: #7f8b00
11: #bb8801
12: #008dd1
13: #6a7fd2
14: #00948b
15: #e7e2d9
foreground: #afaba2
background: #0c1118
cursor: #afaba2

equilibrium-gray-dark
0: #111111
1: #f04339
2: #7f8b00
3: #bb8801
4: #008dd1
5: #6a7fd2
6: #00948b
7: #ababab
8: #777777
9: #f04339
10: #7f8b00
11: #bb8801
12: #008dd1
13: #6a7fd2
14: #00948b
15: #e2e2e2
foreground: #ababab
background: #111111
cursor: #ababab

equilibrium-gray-light
0: #f1f1f1
1: #d02023
2: #637200
3: #9d6f00
4: #0073b5
5: #4e66b6
6: #007a72
7: #474747
8: #777777
9: #d02023
10: #637200
11: #9d6f00
12: #0073b5
13: #4e66b6
14: #007a72
15: #1b1b1b
foreground: #474747
background: #f1f1f1
cursor: #474747

equilibrium-light
0: #f5f0e7
1: #d02023
2: #637200
3: #9d6f00
4: #0073b5
5: #4e66b6
6: #007a72
7: #43474e
8: #73777f
9: #d02023
10: #637200
11: #9d6f00
12: #0073b5
13: #4e66b6
14: #007a72
15: #181c22
foreground: #43474e
background: #f5f0e7
cursor: #43474e

espresso
0: #2d2d2d
1: #d25252
2: #a5c261
3: #ffc66d
4: #6c99bb
5: #d197d9
6: #bed6ff
7: #cccccc
8: #777777
9: #d25252
10: #a5c261
11: #ffc66d
12: #6c99bb
13: #d197d9
14: #bed6ff
15: #ffffff
foreground: #cccccc
background: #2d2d2d
cursor: #cccccc

espresso-libre
0: #000000
1: #cc0000
2: #1a921c
3: #f0e53a
4: #0066ff
5: #c5656b
6: #06989a
7: #d3d7cf
8: #555753
9: #ef2929
10: #9aff87
11: #fffb5c
12: #43a8ed
13: #ff818a
14: #34e2e2
15: #eeeeec
foreground: #b8a898
background: #2a211c
cursor: #b8a898

eva
0: #2a3b4d
1: #c4676c
2: #66ff66
3: #ffff66
4: #15f4ee
5: #9c6cd3
6: #4b8f77
7: #9fa2a6
8: #55799c
9: #c4676c
10: #66ff66
11: #ffff66
12: #15f4ee
13: #9c6cd3
14: #4b8f77
15: #ffffff
foreground: #9fa2a6
background: #2a3b4d
cursor: #9fa2a6

eva-dim
0: #2a3b4d
1: #c4676c
2: #5de561
3: #cfd05d
4: #1ae1dc
5: #9c6cd3
6: #4b8f77
7: #9fa2a6
8: #55799c
9: #c4676c
10: #5de561
11: #cfd05d
12: #1ae1dc
13: #9c6cd3
14: #4b8f77
15: #ffffff
foreground: #9fa2a6
background: #2a3b4d
cursor: #9fa2a6

everforest
0: #4b565c
1: #e67e80
2: #a7c080
3: #dbbc7f
4: #7fbbb3
5: #d699b6
6: #83c092
7: #d3c6aa
8: #4b565c
9: #e67e80
10: #a7c080
11: #dbbc7f
12: #7fbbb3
13: #d699b6
14: #83c092
15: #d3c6aa
foreground: #d3c6aa
background: #2f383e
cursor: #d3c6aa

everforest-light
0: #5c6a72
1: #f85552
2: #8da101
3: #dfa000
4: #3a94c5
5: #df69ba
6: #35a77c
7: #dfddc8
8: #5c6a72
9: #f85552
10: #8da101
11: #dfa000
12: #3a94c5
13: #df69ba
14: #35a77c
15: #dfddc8
foreground: #5c6a72
background: #f8f0dc
cursor: #5c6a72

falcon
0: #000004
1: #ff3600
2: #718e3f
3: #ffc552
4: #635196
5: #ff761a
6: #34bfa4
7: #b4b4b9
8: #020221
9: #ff8e78
10: #b1bf75
11: #ffd392
12: #99a4bc
13: #ffb07b
14: #8bccbf
15: #f8f8ff
foreground: #b4b4b9
background: #020221
cursor: #ffe8c0

farin
0: #444444
1: #ff1155
2: #11ff55
3: #ffbb33
4: #1155ff
5: #ed53c9
6: #00ffbb
7: #cccccc
8: #666666
9: #ff4488
10: #44ff88
11: #ffdd66
12: #4488ff
13: #dd66ff
14: #66ffdd
15: #ffffff
foreground: #aaaaaa
background: #1e1e1e
cursor: #aaaaaa

ffive
0: #000000
1: #ea2639
2: #32bf46
3: #f8f800
4: #356abf
5: #b035c0
6: #54cece
7: #dadadb
8: #565656
9: #ee5463
10: #56d369
11: #ffff24
12: #5b89d2
13: #c04fcf
14: #6dd8d8
15: #ffffff
foreground: #dadadb
background: #1d1e20
cursor: #dadadb

fideloper
0: #282f32
1: #ca1d2c
2: #edb7ab
3: #b7aa9a
4: #2e78c1
5: #c0226e
6: #309185
7: #e9e2cd
8: #092027
9: #d35f5a
10: #d35f5a
11: #a86571
12: #7c84c4
13: #5b5db2
14: #81908f
15: #fcf4de
foreground: #dad9df
background: #282f32
cursor: #d35f5a

fishtank
0: #03073c
1: #c6004a
2: #acf157
3: #fecd5e
4: #525fb8
5: #986f82
6: #968763
7: #ecf0fc
8: #6c5b30
9: #da4b8a
10: #dbffa9
11: #fee6a9
12: #b2befa
13: #fda5cd
14: #a5bd86
15: #f6ffec
foreground: #ecf0fe
background: #232537
cursor: #ecf0fe

flat
0: #2c3e50
1: #e74c3c
2: #2ecc71
3: #f1c40f
4: #3498db
5: #9b59b6
6: #1abc9c
7: #e0e0e0
8: #95a5a6
9: #e74c3c
10: #2ecc71
11: #f1c40f
12: #3498db
13: #9b59b6
14: #1abc9c
15: #ecf0f1
foreground: #e0e0e0
background: #2c3e50
cursor: #e0e0e0

flatland
0: #1d1d19
1: #f18339
2: #9fd364
3: #f4ef6d
4: #5096be
5: #695abc
6: #d63865
7: #ffffff
8: #1d1d19
9: #d22a24
10: #a7d42c
11: #ff8949
12: #61b9d0
13: #695abc
14: #d63865
15: #ffffff
foreground: #b8dbef
background: #1d1f21
cursor: #b8dbef

floraverse
0: #08002e
1: #64002c
2: #5d731a
3: #cd751c
4: #1d6da1
5: #b7077e
6: #42a38c
7: #f3e0b8
8: #331d4c
9: #cf2062
10: #b3ce58
11: #fac357
12: #40a4cf
13: #f02aae
14: #62caa8
15: #fff5db
foreground: #dbd0b9
background: #0e0c15
cursor: #bbbbbb

forest-night
0: #7f8f9f
1: #fd8489
2: #a9dd9d
3: #f0aa8a
4: #bdd0e5
5: #daccf0
6: #a9dd9d
7: #ffebc3
8: #7f8f9f
9: #fd8489
10: #a9dd9d
11: #eed094
12: #bdd0e5
13: #daccf0
14: #a9dd9d
15: #ffebc3
foreground: #ffebc3
background: #3c4c55
cursor: #ffebc3

foxnightly
0: #2a2a2e
1: #b98eff
2: #ff7de9
3: #729fcf
4: #66a05b
5: #75507b
6: #acacae
7: #ffffff
8: #a40000
9: #bf4040
10: #66a05b
11: #ffb86c
12: #729fcf
13: #8f5902
14: #c4a000
15: #5c3566
foreground: #d7d7db
background: #2a2a2e
cursor: #d7d7db

framer
0: #181818
1: #fd886b
2: #32ccdc
3: #fecb6e
4: #20bcfc
5: #ba8cfc
6: #acddfd
7: #d0d0d0
8: #747474
9: #fd886b
10: #32ccdc
11: #fecb6e
12: #20bcfc
13: #ba8cfc
14: #acddfd
15: #eeeeee
foreground: #d0d0d0
background: #181818
cursor: #d0d0d0

freya
0: #073642
1: #dc322f
2: #859900
3: #b58900
4: #268bd2
5: #ec0048
6: #2aa198
7: #94a3a5
8: #586e75
9: #cb4b16
10: #859900
11: #b58900
12: #268bd2
13: #d33682
14: #2aa198
15: #6c71c4
foreground: #94a3a5
background: #252e32
cursor: #839496

frontend-delight
0: #242526
1: #f8511b
2: #565747
3: #fa771d
4: #2c70b7
5: #f02e4f
6: #3ca1a6
7: #adadad
8: #5fac6d
9: #f74319
10: #74ec4c
11: #fdc325
12: #3393ca
13: #e75e4f
14: #4fbce6
15: #8c735b
foreground: #adadad
background: #1b1c1d
cursor: #adadad

frontend-fun-forrest
0: #000000
1: #d6262b
2: #919c00
3: #be8a13
4: #4699a3
5: #8d4331
6: #da8213
7: #ddc265
8: #7f6a55
9: #e55a1c
10: #bfc65a
11: #ffcb1b
12: #7cc9cf
13: #d26349
14: #e6a96b
15: #ffeaa3
foreground: #dec165
background: #251200
cursor: #dec165

frontend-galaxy
0: #000000
1: #f9555f
2: #21b089
3: #fef02a
4: #589df6
5: #944d95
6: #1f9ee7
7: #bbbbbb
8: #555555
9: #fa8c8f
10: #35bb9a
11: #ffff55
12: #589df6
13: #e75699
14: #3979bc
15: #ffffff
foreground: #ffffff
background: #1d2837
cursor: #ffffff

fruit-soda
0: #f1ecf1
1: #fe3e31
2: #47f74c
3: #f7e203
4: #2931df
5: #611fce
6: #0f9cfd
7: #515151
8: #b5b4b6
9: #fe3e31
10: #47f74c
11: #f7e203
12: #2931df
13: #611fce
14: #0f9cfd
15: #2d2c2c
foreground: #515151
background: #f1ecf1
cursor: #515151

gigavolt
0: #202126
1: #ff661a
2: #f2e6a9
3: #ffdc2d
4: #40bfff
5: #ae94f9
6: #fb6acb
7: #e9e7e1
8: #a1d2e6
9: #ff661a
10: #f2e6a9
11: #ffdc2d
12: #40bfff
13: #ae94f9
14: #fb6acb
15: #f2fbff
foreground: #e9e7e1
background: #202126
cursor: #e9e7e1

github
0: #ffffff
1: #ed6a43
2: #183691
3: #795da3
4: #795da3
5: #a71d5d
6: #183691
7: #333333
8: #969896
9: #ed6a43
10: #183691
11: #795da3
12: #795da3
13: #a71d5d
14: #183691
15: #ffffff
foreground: #333333
background: #ffffff
cursor: #333333

github-dark
0: #586069
1: #ea4a5a
2: #34d058
3: #ffea7f
4: #2188ff
5: #b392f0
6: #39c5cf
7: #d1d5da
8: #959da5
9: #f97583
10: #85e89d
11: #ffea7f
12: #79b8ff
13: #b392f0
14: #56d4dd
15: #fafbfc
foreground: #d1d5da
background: #24292e
cursor: #c8e1ff

github-dark-colorblind
0: #484f58
1: #ff7b72
2: #3fb950
3: #d29922
4: #58a6ff
5: #bc8cff
6: #39c5cf
7: #b1bac4
8: #6e7681
9: #ffa198
10: #56d364
11: #e3b341
12: #79c0ff
13: #d2a8ff
14: #56d4dd
15: #f0f6fc
foreground: #b3b1ad
background: #0d1117
cursor: #73b7f2

github-dark-default
0: #484f58
1: #ff7b72
2: #3fb950
3: #d29922
4: #58a6ff
5: #bc8cff
6: #39c5cf
7: #b1bac4
8: #6e7681
9: #ffa198
10: #56d364
11: #e3b341
12: #79c0ff
13: #d2a8ff
14: #56d4dd
15: #f0f6fc
foreground: #b3b1ad
background: #0d1117
cursor: #73b7f2

github-dimmed
0: #545d68
1: #f47067
2: #57ab5a
3: #c69026
4: #539bf5
5: #b083f0
6: #39c5cf
7: #909dab
8: #636e7b
9: #ff938a
10: #6bc46d
11: #daaa3f
12: #6cb6ff
13: #dcbdfb
14: #56d4dd
15: #cdd9e5
foreground: #768390
background: #22272e
cursor: #6cb6ff

github-light
0: #24292e
1: #d73a49
2: #28a745
3: #dbab09
4: #0366d6
5: #5a32a3
6: #0598bc
7: #6a737d
8: #959da5
9: #cb2431
10: #22863a
11: #b08800
12: #005cc5
13: #5a32a3
14: #3192aa
15: #d1d5da
foreground: #24292f
background: #ffffff
cursor: #044289

github-light-colorblind
0: #24292f
1: #cf222e
2: #116329
3: #4d2d00
4: #0969da
5: #8250df
6: #1b7c83
7: #6e7781
8: #57606a
9: #a40e26
10: #1a7f37
11: #633c01
12: #218bff
13: #a475f9
14: #3192aa
15: #8c959f
foreground: #0e1116
background: #ffffff
cursor: #0969da

github-light-default
0: #24292f
1: #cf222e
2: #116329
3: #4d2d00
4: #0969da
5: #8250df
6: #1b7c83
7: #6e7781
8: #57606a
9: #a40e26
10: #1a7f37
11: #633c01
12: #218bff
13: #a475f9
14: #3192aa
15: #8c959f
foreground: #0e1116
background: #ffffff
cursor: #044289

glacier
0: #2e343c
1: #bd0f2f
2: #35a770
3: #fb9435
4: #1f5872
5: #bd2523
6: #778397
7: #ffffff
8: #404a55
9: #bd0f2f
10: #49e998
11: #fddf6e
12: #2a8bc1
13: #ea4727
14: #a0b6d3
15: #ffffff
foreground: #ffffff
background: #0c1115
cursor: #6c6c6c

goa-base
0: #880041
1: #f78000
2: #249000
3: #f40000
4: #000482
5: #f43bff
6: #3affff
7: #000000
8: #411a6d
9: #f800e1
10: #5743ff
11: #ea00d7
12: #b90003
13: #9a5952
14: #c8f9f3
15: #f5f4fb
foreground: #f6ed00
background: #2f0033
cursor: #1a6500

gooey
0: #000009
1: #bb4f6c
2: #72ccae
3: #c65e3d
4: #58b6ca
5: #6488c4
6: #8d84c6
7: #858893
8: #1f222d
9: #ee829f
10: #a5ffe1
11: #f99170
12: #8be9fd
13: #97bbf7
14: #c0b7f9
15: #ffffff
foreground: #ebeef9
background: #0d101b
cursor: #ebeef9

google-dark
0: #1d1f21
1: #cc342b
2: #198844
3: #fba922
4: #3971ed
5: #a36ac7
6: #3971ed
7: #c5c8c6
8: #969896
9: #cc342b
10: #198844
11: #fba922
12: #3971ed
13: #a36ac7
14: #3971ed
15: #ffffff
foreground: #c5c8c6
background: #1d1f21
cursor: #c5c8c6

google-light
0: #ffffff
1: #cc342b
2: #198844
3: #fba922
4: #3971ed
5: #a36ac7
6: #3971ed
7: #373b41
8: #b4b7b4
9: #cc342b
10: #198844
11: #fba922
12: #3971ed
13: #a36ac7
14: #3971ed
15: #1d1f21
foreground: #373b41
background: #ffffff
cursor: #373b41

grape
0: #2d283f
1: #ed2261
2: #1fa91b
3: #8ddc20
4: #487df4
5: #8d35c9
6: #3bdeed
7: #9e9ea0
8: #59516a
9: #f0729a
10: #53aa5e
11: #b2dc87
12: #a9bcec
13: #ad81c2
14: #9de3eb
15: #a288f7
foreground: #9f9fa1
background: #171423
cursor: #9f9fa1

grass
0: #000000
1: #bb0000
2: #00bb00
3: #e7b000
4: #0000a3
5: #950062
6: #00bbbb
7: #bbbbbb
8: #555555
9: #bb0000
10: #00bb00
11: #e7b000
12: #0000bb
13: #ff55ff
14: #55ffff
15: #ffffff
foreground: #fff0a5
background: #13773d
cursor: #fff0a5

grayscale-dark
0: #101010
1: #7c7c7c
2: #8e8e8e
3: #a0a0a0
4: #686868
5: #747474
6: #868686
7: #b9b9b9
8: #525252
9: #7c7c7c
10: #8e8e8e
11: #a0a0a0
12: #686868
13: #747474
14: #868686
15: #f7f7f7
foreground: #b9b9b9
background: #101010
cursor: #b9b9b9

grayscale-light
0: #f7f7f7
1: #7c7c7c
2: #8e8e8e
3: #a0a0a0
4: #686868
5: #747474
6: #868686
7: #464646
8: #ababab
9: #7c7c7c
10: #8e8e8e
11: #a0a0a0
12: #686868
13: #747474
14: #868686
15: #101010
foreground: #464646
background: #f7f7f7
cursor: #464646

green-screen
0: #001100
1: #007700
2: #00bb00
3: #007700
4: #009900
5: #00bb00
6: #005500
7: #00bb00
8: #007700
9: #007700
10: #00bb00
11: #007700
12: #009900
13: #00bb00
14: #005500
15: #00ff00
foreground: #00bb00
background: #001100
cursor: #00bb00

greenscreen
0: #001100
1: #007700
2: #00bb00
3: #007700
4: #009900
5: #00bb00
6: #005500
7: #00bb00
8: #007700
9: #007700
10: #00bb00
11: #007700
12: #009900
13: #00bb00
14: #005500
15: #00ff00
foreground: #00bb00
background: #001100
cursor: #00bb00

gruvbit
0: #1d2021
1: #fabd2f
2: #8ec07c
3: #dc9656
4: #83a598
5: #fe8019
6: #e9593d
7: #504945
8: #968772
9: #fabd2f
10: #8ec07c
11: #dc9656
12: #83a598
13: #fe8019
14: #e9593d
15: #e9593d
foreground: #ebdbb2
background: #1d1f21
cursor: #ebdbb2

gruvbox
0: #fbf1c7
1: #cc241d
2: #98971a
3: #d79921
4: #458588
5: #b16286
6: #689d6a
7: #7c6f64
8: #928374
9: #9d0006
10: #79740e
11: #b57614
12: #076678
13: #8f3f71
14: #427b58
15: #3c3836
foreground: #3c3836
background: #fbf1c7
cursor: #3c3836

gruvbox-dark
0: #282828
1: #cc241d
2: #98971a
3: #d79921
4: #458588
5: #b16286
6: #689d6a
7: #a89984
8: #928374
9: #fb4934
10: #b8bb26
11: #fabd2f
12: #83a598
13: #d3869b
14: #8ec07c
15: #ebdbb2
foreground: #ebdbb2
background: #282828
cursor: #ebdbb2

gruvbox-dark-hard
0: #1d2021
1: #fb4934
2: #b8bb26
3: #fabd2f
4: #83a598
5: #d3869b
6: #8ec07c
7: #d5c4a1
8: #665c54
9: #fb4934
10: #b8bb26
11: #fabd2f
12: #83a598
13: #d3869b
14: #8ec07c
15: #fbf1c7
foreground: #d5c4a1
background: #1d2021
cursor: #d5c4a1

gruvbox-dark-medium
0: #282828
1: #fb4934
2: #b8bb26
3: #fabd2f
4: #83a598
5: #d3869b
6: #8ec07c
7: #d5c4a1
8: #665c54
9: #fb4934
10: #b8bb26
11: #fabd2f
12: #83a598
13: #d3869b
14: #8ec07c
15: #fbf1c7
foreground: #d5c4a1
background: #282828
cursor: #d5c4a1

gruvbox-dark-pale
0: #262626
1: #d75f5f
2: #afaf00
3: #ffaf00
4: #83adad
5: #d485ad
6: #85ad85
7: #dab997
8: #8a8a8a
9: #d75f5f
10: #afaf00
11: #ffaf00
12: #83adad
13: #d485ad
14: #85ad85
15: #ebdbb2
foreground: #dab997
background: #262626
cursor: #dab997

gruvbox-dark-soft
0: #32302f
1: #fb4934
2: #b8bb26
3: #fabd2f
4: #83a598
5: #d3869b
6: #8ec07c
7: #d5c4a1
8: #665c54
9: #fb4934
10: #b8bb26
11: #fabd2f
12: #83a598
13: #d3869b
14: #8ec07c
15: #fbf1c7
foreground: #d5c4a1
background: #32302f
cursor: #d5c4a1

gruvbox-light-hard
0: #f9f5d7
1: #9d0006
2: #79740e
3: #b57614
4: #076678
5: #8f3f71
6: #427b58
7: #504945
8: #bdae93
9: #9d0006
10: #79740e
11: #b57614
12: #076678
13: #8f3f71
14: #427b58
15: #282828
foreground: #504945
background: #f9f5d7
cursor: #504945

gruvbox-light-medium
0: #fbf1c7
1: #9d0006
2: #79740e
3: #b57614
4: #076678
5: #8f3f71
6: #427b58
7: #504945
8: #bdae93
9: #9d0006
10: #79740e
11: #b57614
12: #076678
13: #8f3f71
14: #427b58
15: #282828
foreground: #504945
background: #fbf1c7
cursor: #504945

gruvbox-light-soft
0: #f2e5bc
1: #9d0006
2: #79740e
3: #b57614
4: #076678
5: #8f3f71
6: #427b58
7: #504945
8: #bdae93
9: #9d0006
10: #79740e
11: #b57614
12: #076678
13: #8f3f71
14: #427b58
15: #282828
foreground: #504945
background: #f2e5bc
cursor: #504945

gruvbox-material-dark-hard
0: #1d2021
1: #ea6962
2: #a9b665
3: #d8a657
4: #7daea3
5: #d3869b
6: #89b482
7: #d4be98
8: #1d2021
9: #ea6962
10: #a9b665
11: #d8a657
12: #7daea3
13: #d3869b
14: #89b482
15: #d4be98
foreground: #d4be98
background: #1d2021
cursor: #d4be98

gruvbox-material-dark-medium
0: #282828
1: #ea6962
2: #a9b665
3: #d8a657
4: #7daea3
5: #d3869b
6: #89b482
7: #d4be98
8: #282828
9: #ea6962
10: #a9b665
11: #d8a657
12: #7daea3
13: #d3869b
14: #89b482
15: #d4be98
foreground: #d4be98
background: #282828
cursor: #d4be98

gruvbox-material-dark-soft
0: #32302f
1: #ea6962
2: #a9b665
3: #d8a657
4: #7daea3
5: #d3869b
6: #89b482
7: #d4be98
8: #32302f
9: #ea6962
10: #a9b665
11: #d8a657
12: #7daea3
13: #d3869b
14: #89b482
15: #d4be98
foreground: #d4be98
background: #32302f
cursor: #d4be98

gruvbox-material-light-hard
0: #f9f5d7
1: #c14a4a
2: #6c782e
3: #b47109
4: #45707a
5: #945e80
6: #4c7a5d
7: #654735
8: #f9f5d7
9: #c14a4a
10: #6c782e
11: #b47109
12: #45707a
13: #945e80
14: #4c7a5d
15: #654735
foreground: #654735
background: #f9f5d7
cursor: #654735

gruvbox-material-light-medium
0: #fbf1c7
1: #c14a4a
2: #6c782e
3: #b47109
4: #45707a
5: #945e80
6: #4c7a5d
7: #654735
8: #fbf1c7
9: #c14a4a
10: #6c782e
11: #b47109
12: #45707a
13: #945e80
14: #4c7a5d
15: #654735
foreground: #654735
background: #fbf1c7
cursor: #654735

gruvbox-material-light-soft
0: #f2e5bc
1: #c14a4a
2: #6c782e
3: #b47109
4: #45707a
5: #945e80
6: #4c7a5d
7: #654735
8: #f2e5bc
9: #c14a4a
10: #6c782e
11: #b47109
12: #45707a
13: #945e80
14: #4c7a5d
15: #654735
foreground: #654735
background: #f2e5bc
cursor: #654735

gruvbox-mix-dark-hard
0: #1d2021
1: #f2594b
2: #b0b846
3: #e9b143
4: #80aa9e
5: #d3869b
6: #8bba7f
7: #e2cca9
8: #1d2021
9: #f2594b
10: #b0b846
11: #e9b143
12: #80aa9e
13: #d3869b
14: #8bba7f
15: #e2cca9
foreground: #e2cca9
background: #1d2021
cursor: #e2cca9

gruvbox-mix-dark-medium
0: #282828
1: #f2594b
2: #b0b846
3: #e9b143
4: #80aa9e
5: #d3869b
6: #8bba7f
7: #e2cca9
8: #282828
9: #f2594b
10: #b0b846
11: #e9b143
12: #80aa9e
13: #d3869b
14: #8bba7f
15: #e2cca9
foreground: #e2cca9
background: #282828
cursor: #e2cca9

gruvbox-mix-dark-soft
0: #32302f
1: #f2594b
2: #b0b846
3: #e9b143
4: #80aa9e
5: #d3869b
6: #8bba7f
7: #e2cca9
8: #32302f
9: #f2594b
10: #b0b846
11: #e9b143
12: #80aa9e
13: #d3869b
14: #8bba7f
15: #e2cca9
foreground: #e2cca9
background: #32302f
cursor: #e2cca9

gruvbox-mix-light-hard
0: #f9f5d7
1: #af2528
2: #72761e
3: #b4730e
4: #266b79
5: #924f79
6: #477a5b
7: #514036
8: #f9f5d7
9: #af2528
10: #72761e
11: #b4730e
12: #266b79
13: #924f79
14: #477a5b
15: #514036
foreground: #514036
background: #f9f5d7
cursor: #514036

gruvbox-mix-light-medium
0: #fbf1c7
1: #af2528
2: #72761e
3: #b4730e
4: #266b79
5: #924f79
6: #477a5b
7: #514036
8: #fbf1c7
9: #af2528
10: #72761e
11: #b4730e
12: #266b79
13: #924f79
14: #477a5b
15: #514036
foreground: #514036
background: #fbf1c7
cursor: #514036

gruvbox-mix-light-soft
0: #f2e5bc
1: #af2528
2: #72761e
3: #b4730e
4: #266b79
5: #924f79
6: #477a5b
7: #514036
8: #f2e5bc
9: #af2528
10: #72761e
11: #b4730e
12: #266b79
13: #924f79
14: #477a5b
15: #514036
foreground: #514036
background: #f2e5bc
cursor: #514036

gruvbox-original-dark-hard
0: #1d2021
1: #fb4934
2: #b8bb26
3: #fabd2f
4: #83a598
5: #d3869b
6: #8ec07c
7: #ebdbb2
8: #1d2021
9: #fb4934
10: #b8bb26
11: #fabd2f
12: #83a598
13: #d3869b
14: #8ec07c
15: #ebdbb2
foreground: #ebdbb2
background: #1d2021
cursor: #ebdbb2

gruvbox-original-dark-medium
0: #282828
1: #fb4934
2: #b8bb26
3: #fabd2f
4: #83a598
5: #d3869b
6: #8ec07c
7: #ebdbb2
8: #282828
9: #fb4934
10: #b8bb26
11: #fabd2f
12: #83a598
13: #d3869b
14: #8ec07c
15: #ebdbb2
foreground: #ebdbb2
background: #282828
cursor: #ebdbb2

gruvbox-original-dark-soft
0: #32302f
1: #fb4934
2: #b8bb26
3: #fabd2f
4: #83a598
5: #d3869b
6: #8ec07c
7: #ebdbb2
8: #32302f
9: #fb4934
10: #b8bb26
11: #fabd2f
12: #83a598
13: #d3869b
14: #8ec07c
15: #ebdbb2
foreground: #ebdbb2
background: #32302f
cursor: #ebdbb2

gruvbox-original-light-hard
0: #f9f5d7
1: #9d0006
2: #79740e
3: #b57614
4: #076678
5: #8f3f71
6: #427b58
7: #3c3836
8: #f9f5d7
9: #9d0006
10: #79740e
11: #b57614
12: #076678
13: #8f3f71
14: #427b58
15: #3c3836
foreground: #3c3836
background: #f9f5d7
cursor: #3c3836

gruvbox-original-light-medium
0: #fbf1c7
1: #9d0006
2: #79740e
3: #b57614
4: #076678
5: #8f3f71
6: #427b58
7: #3c3836
8: #fbf1c7
9: #9d0006
10: #79740e
11: #b57614
12: #076678
13: #8f3f71
14: #427b58
15: #3c3836
foreground: #3c3836
background: #fbf1c7
cursor: #3c3836

gruvbox-original-light-soft
0: #f2e5bc
1: #9d0006
2: #79740e
3: #b57614
4: #076678
5: #8f3f71
6: #427b58
7: #3c3836
8: #f2e5bc
9: #9d0006
10: #79740e
11: #b57614
12: #076678
13: #8f3f71
14: #427b58
15: #3c3836
foreground: #3c3836
background: #f2e5bc
cursor: #3c3836

hardcore
0: #212121
1: #f92672
2: #a6e22e
3: #e6db74
4: #66d9ef
5: #9e6ffe
6: #708387
7: #cdcdcd
8: #4a4a4a
9: #f92672
10: #a6e22e
11: #e6db74
12: #66d9ef
13: #9e6ffe
14: #708387
15: #ffffff
foreground: #cdcdcd
background: #212121
cursor: #cdcdcd

harmonic-dark
0: #0b1c2c
1: #bf8b56
2: #56bf8b
3: #8bbf56
4: #8b56bf
5: #bf568b
6: #568bbf
7: #cbd6e2
8: #627e99
9: #bf8b56
10: #56bf8b
11: #8bbf56
12: #8b56bf
13: #bf568b
14: #568bbf
15: #f7f9fb
foreground: #cbd6e2
background: #0b1c2c
cursor: #cbd6e2

harmonic-light
0: #f7f9fb
1: #bf8b56
2: #56bf8b
3: #8bbf56
4: #8b56bf
5: #bf568b
6: #568bbf
7: #405c79
8: #aabcce
9: #bf8b56
10: #56bf8b
11: #8bbf56
12: #8b56bf
13: #bf568b
14: #568bbf
15: #0b1c2c
foreground: #405c79
background: #f7f9fb
cursor: #405c79

harmonic16-dark
0: #0b1c2c
1: #bf8b56
2: #56bf8b
3: #8bbf56
4: #8b56bf
5: #bf568b
6: #568bbf
7: #cbd6e2
8: #627e99
9: #bf8b56
10: #56bf8b
11: #8bbf56
12: #8b56bf
13: #bf568b
14: #568bbf
15: #f7f9fb
foreground: #cbd6e2
background: #0b1c2c
cursor: #cbd6e2

harmonic16-light
0: #f7f9fb
1: #bf8b56
2: #56bf8b
3: #8bbf56
4: #8b56bf
5: #bf568b
6: #568bbf
7: #405c79
8: #aabcce
9: #bf8b56
10: #56bf8b
11: #8bbf56
12: #8b56bf
13: #bf568b
14: #568bbf
15: #0b1c2c
foreground: #405c79
background: #f7f9fb
cursor: #405c79

harper
0: #010101
1: #f8b63f
2: #7fb5e1
3: #d6da25
4: #489e48
5: #b296c6
6: #f5bfd7
7: #a8a49d
8: #726e6a
9: #f8b63f
10: #7fb5e1
11: #d6da25
12: #489e48
13: #b296c6
14: #f5bfd7
15: #fefbea
foreground: #a8a49d
background: #010101
cursor: #a8a49d

heetch
0: #190134
1: #27d9d5
2: #c33678
3: #8f6c97
4: #bd0152
5: #82034c
6: #f80059
7: #bdb6c5
8: #7b6d8b
9: #27d9d5
10: #c33678
11: #8f6c97
12: #bd0152
13: #82034c
14: #f80059
15: #feffff
foreground: #bdb6c5
background: #190134
cursor: #bdb6c5

heetch-light
0: #feffff
1: #27d9d5
2: #f80059
3: #5ba2b6
4: #47f9f5
5: #bd0152
6: #c33678
7: #5a496e
8: #9c92a8
9: #27d9d5
10: #f80059
11: #5ba2b6
12: #47f9f5
13: #bd0152
14: #c33678
15: #190134
foreground: #5a496e
background: #feffff
cursor: #5a496e

helios
0: #1d2021
1: #d72638
2: #88b92d
3: #f19d1a
4: #1e8bac
5: #be4264
6: #1ba595
7: #d5d5d5
8: #6f7579
9: #d72638
10: #88b92d
11: #f19d1a
12: #1e8bac
13: #be4264
14: #1ba595
15: #e5e5e5
foreground: #d5d5d5
background: #1d2021
cursor: #d5d5d5

hemisu-dark
0: #444444
1: #ff0054
2: #b1d630
3: #9d895e
4: #67bee3
5: #b576bc
6: #569a9f
7: #ededed
8: #777777
9: #d65e75
10: #baffaa
11: #ece1c8
12: #9fd3e5
13: #deb3df
14: #b6e0e5
15: #ffffff
foreground: #ffffff
background: #000000
cursor: #baffaa

hemisu-light
0: #777777
1: #ff0055
2: #739100
3: #503d15
4: #538091
5: #5b345e
6: #538091
7: #999999
8: #999999
9: #d65e76
10: #9cc700
11: #947555
12: #9db3cd
13: #a184a4
14: #85b2aa
15: #bababa
foreground: #444444
background: #efefef
cursor: #ff0054

highway
0: #000000
1: #d00e18
2: #138034
3: #ffcb3e
4: #006bb3
5: #6b2775
6: #384564
7: #ededed
8: #5d504a
9: #f07e18
10: #b1d130
11: #fff120
12: #4fc2fd
13: #de0071
14: #5d504a
15: #ffffff
foreground: #ededed
background: #222225
cursor: #ededed

hipster-green
0: #000000
1: #b6214a
2: #00a600
3: #bfbf00
4: #246eb2
5: #b200b2
6: #00a6b2
7: #bfbfbf
8: #666666
9: #e50000
10: #86a93e
11: #e5e500
12: #0000ff
13: #e500e5
14: #00e5e5
15: #e5e5e5
foreground: #84c138
background: #100b05
cursor: #84c138

homebrew
0: #000000
1: #990000
2: #00a600
3: #999900
4: #0000b2
5: #b200b2
6: #00a6b2
7: #bfbfbf
8: #666666
9: #e50000
10: #00d900
11: #e5e500
12: #0000ff
13: #e500e5
14: #00e5e5
15: #e5e5e5
foreground: #00ff00
background: #000000
cursor: #00ff00

hopscotch
0: #322931
1: #dd464c
2: #8fc13e
3: #fdcc59
4: #1290bf
5: #c85e7c
6: #149b93
7: #b9b5b8
8: #797379
9: #dd464c
10: #8fc13e
11: #fdcc59
12: #1290bf
13: #c85e7c
14: #149b93
15: #ffffff
foreground: #b9b5b8
background: #322931
cursor: #b9b5b8

horizon-dark
0: #1c1e26
1: #e93c58
2: #efaf8e
3: #efb993
4: #df5273
5: #b072d1
6: #24a8b4
7: #cbced0
8: #6f6f70
9: #e93c58
10: #efaf8e
11: #efb993
12: #df5273
13: #b072d1
14: #24a8b4
15: #e3e6ee
foreground: #cbced0
background: #1c1e26
cursor: #cbced0

horizon-light
0: #fdf0ed
1: #f7939b
2: #94e1b0
3: #fbe0d9
4: #da103f
5: #1d8991
6: #dc3318
7: #403c3d
8: #bdb3b1
9: #f7939b
10: #94e1b0
11: #fbe0d9
12: #da103f
13: #1d8991
14: #dc3318
15: #201c1d
foreground: #403c3d
background: #fdf0ed
cursor: #403c3d

horizon-terminal-dark
0: #1c1e26
1: #e95678
2: #29d398
3: #fac29a
4: #26bbd9
5: #ee64ac
6: #59e1e3
7: #cbced0
8: #6f6f70
9: #e95678
10: #29d398
11: #fac29a
12: #26bbd9
13: #ee64ac
14: #59e1e3
15: #e3e6ee
foreground: #cbced0
background: #1c1e26
cursor: #cbced0

horizon-terminal-light
0: #fdf0ed
1: #e95678
2: #29d398
3: #fadad1
4: #26bbd9
5: #ee64ac
6: #59e1e3
7: #403c3d
8: #bdb3b1
9: #e95678
10: #29d398
11: #fadad1
12: #26bbd9
13: #ee64ac
14: #59e1e3
15: #201c1d
foreground: #403c3d
background: #fdf0ed
cursor: #403c3d

humanoid-dark
0: #232629
1: #f11235
2: #02d849
3: #ffb627
4: #00a6fb
5: #f15ee3
6: #0dd9d6
7: #f8f8f2
8: #60615d
9: #f11235
10: #02d849
11: #ffb627
12: #00a6fb
13: #f15ee3
14: #0dd9d6
15: #fcfcfc
foreground: #f8f8f2
background: #232629
cursor: #f8f8f2

humanoid-light
0: #f8f8f2
1: #b0151a
2: #388e3c
3: #ffb627
4: #0082c9
5: #700f98
6: #008e8e
7: #232629
8: #c0c0bd
9: #b0151a
10: #388e3c
11: #ffb627
12: #0082c9
13: #700f98
14: #008e8e
15: #070708
foreground: #232629
background: #f8f8f2
cursor: #232629

hurtado
0: #575757
1: #ff1b00
2: #a5e055
3: #fbe74a
4: #496487
5: #fd5ff1
6: #86e9fe
7: #cbcccb
8: #262626
9: #d51d00
10: #a5df55
11: #fbe84a
12: #89beff
13: #c001c1
14: #86eafe
15: #dbdbdb
foreground: #dbdbdb
background: #000000
cursor: #dbdbdb

hybrid
0: #282a2e
1: #a54242
2: #8c9440
3: #de935f
4: #5f819d
5: #85678f
6: #5e8d87
7: #969896
8: #373b41
9: #cc6666
10: #b5bd68
11: #f0c674
12: #81a2be
13: #b294bb
14: #8abeb7
15: #c5c8c6
foreground: #94a3a5
background: #141414
cursor: #94a3a5

ia-dark
0: #1a1a1a
1: #d88568
2: #83a471
3: #b99353
4: #8eccdd
5: #b98eb2
6: #7c9cae
7: #cccccc
8: #767676
9: #d88568
10: #83a471
11: #b99353
12: #8eccdd
13: #b98eb2
14: #7c9cae
15: #f8f8f8
foreground: #cccccc
background: #1a1a1a
cursor: #cccccc

ia-light
0: #f6f6f6
1: #9c5a02
2: #38781c
3: #c48218
4: #48bac2
5: #a94598
6: #2d6bb1
7: #181818
8: #898989
9: #9c5a02
10: #38781c
11: #c48218
12: #48bac2
13: #a94598
14: #2d6bb1
15: #f8f8f8
foreground: #181818
background: #f6f6f6
cursor: #181818

ibm3270
0: #222222
1: #f01818
2: #24d830
3: #f0d824
4: #7890f0
5: #f078d8
6: #54e4e4
7: #a5a5a5
8: #888888
9: #ef8383
10: #7ed684
11: #efe28b
12: #b3bfef
13: #efb3e3
14: #9ce2e2
15: #ffffff
foreground: #fdfdfd
background: #000000
cursor: #fdfdfd

ic-green-ppl
0: #1f1f1f
1: #fb002a
2: #339c24
3: #659b25
4: #149b45
5: #53b82c
6: #2cb868
7: #e0ffef
8: #032710
9: #a7ff3f
10: #9fff6d
11: #d2ff6d
12: #72ffb5
13: #50ff3e
14: #22ff71
15: #daefd0
foreground: #d9efd3
background: #3a3d3f
cursor: #d9efd3

ic-orange-ppl
0: #000000
1: #c13900
2: #a4a900
3: #caaf00
4: #bd6d00
5: #fc5e00
6: #f79500
7: #ffc88a
8: #6a4f2a
9: #ff8c68
10: #f6ff40
11: #ffe36e
12: #ffbe55
13: #fc874f
14: #c69752
15: #fafaff
foreground: #ffcb83
background: #262626
cursor: #ffcb83

iceberg-light
0: #dcdfe7
1: #cc517a
2: #668e3d
3: #c57339
4: #2d539e
5: #7759b4
6: #3f83a6
7: #33374c
8: #8389a3
9: #cc3768
10: #598030
11: #b6662d
12: #22478e
13: #6845ad
14: #327698
15: #262a3f
foreground: #33374c
background: #e8e9ec
cursor: #33374c

icy
0: #021012
1: #16c1d9
2: #4dd0e1
3: #80deea
4: #00bcd4
5: #00acc1
6: #26c6da
7: #095b67
8: #052e34
9: #16c1d9
10: #4dd0e1
11: #80deea
12: #00bcd4
13: #00acc1
14: #26c6da
15: #109cb0
foreground: #095b67
background: #021012
cursor: #095b67

idle-toes
0: #323232
1: #d25252
2: #7fe173
3: #ffc66d
4: #4099ff
5: #f680ff
6: #bed6ff
7: #eeeeec
8: #535353
9: #f07070
10: #9dff91
11: #ffe48b
12: #5eb7f7
13: #ff9dff
14: #dcf4ff
15: #ffffff
foreground: #ffffff
background: #323232
cursor: #ffffff

idm_3b
0: #1a1a1a
1: #b04060
2: #70d0a0
3: #ffb060
4: #408aca
5: #ba5aba
6: #a070e0
7: #606060
8: #b0b0b0
9: #d06080
10: #aaf0d0
11: #ffda90
12: #80baf0
13: #ffb0d0
14: #caa0f0
15: #e0e0e0
foreground: #ffcada
background: #200a28
cursor: #ffa0a0

ir-black
0: #000000
1: #ff6c60
2: #a8ff60
3: #ffffb6
4: #96cbfe
5: #ff73fd
6: #c6c5fe
7: #b5b3aa
8: #6c6c66
9: #ff6c60
10: #a8ff60
11: #ffffb6
12: #96cbfe
13: #ff73fd
14: #c6c5fe
15: #fdfbee
foreground: #b5b3aa
background: #000000
cursor: #b5b3aa

irblack
0: #000000
1: #ff6c60
2: #a8ff60
3: #ffffb6
4: #96cbfe
5: #ff73fd
6: #c6c5fe
7: #b5b3aa
8: #6c6c66
9: #ff6c60
10: #a8ff60
11: #ffffb6
12: #96cbfe
13: #ff73fd
14: #c6c5fe
15: #fdfbee
foreground: #b5b3aa
background: #000000
cursor: #b5b3aa

isotope
0: #000000
1: #ff0000
2: #33ff00
3: #ff0099
4: #0066ff
5: #cc00ff
6: #00ffff
7: #d0d0d0
8: #808080
9: #ff0000
10: #33ff00
11: #ff0099
12: #0066ff
13: #cc00ff
14: #00ffff
15: #ffffff
foreground: #d0d0d0
background: #000000
cursor: #d0d0d0

jackie-brown
0: #2c1d16
1: #ef5734
2: #2baf2b
3: #bebf00
4: #246eb2
5: #d05ec1
6: #00acee
7: #bfbfbf
8: #666666
9: #e50000
10: #86a93e
11: #e5e500
12: #0000ff
13: #e500e5
14: #00e5e5
15: #e5e5e5
foreground: #ffcc2f
background: #2c1d16
cursor: #ffcc2f

japanesque
0: #343935
1: #cf3f61
2: #7bb75b
3: #e9b32a
4: #4c9ad4
5: #a57fc4
6: #389aad
7: #fafaf6
8: #595b59
9: #d18fa6
10: #767f2c
11: #78592f
12: #135979
13: #604291
14: #76bbca
15: #b2b5ae
foreground: #f7f6ec
background: #1e1e1e
cursor: #f7f6ec

jellybeans
0: #929292
1: #e27373
2: #94b979
3: #ffba7b
4: #97bedc
5: #e1c0fa
6: #00988e
7: #dedede
8: #bdbdbd
9: #ffa1a1
10: #bddeab
11: #ffdca0
12: #b1d8f6
13: #fbdaff
14: #1ab2a8
15: #ffffff
foreground: #dedede
background: #121212
cursor: #dedede

jet-brains-darcula
0: #000000
1: #fa5355
2: #126e00
3: #c2c300
4: #4581eb
5: #fa54ff
6: #33c2c1
7: #adadad
8: #545454
9: #fb7172
10: #67ff4f
11: #ffff00
12: #6d9df1
13: #fb82ff
14: #60d3d1
15: #eeeeee
foreground: #adadad
background: #202020
cursor: #ffffff

jup
0: #000000
1: #dd006f
2: #6fdd00
3: #dd6f00
4: #006fdd
5: #6f00dd
6: #00dd6f
7: #f2f2f2
8: #7d7d7d
9: #ff74b9
10: #b9ff74
11: #ffb974
12: #74b9ff
13: #b974ff
14: #74ffb9
15: #ffffff
foreground: #23476a
background: #758480
cursor: #23476a

kibble
0: #4d4d4d
1: #c70031
2: #29cf13
3: #d8e30e
4: #3449d1
5: #8400ff
6: #0798ab
7: #e2d1e3
8: #5a5a5a
9: #f01578
10: #6ce05c
11: #f3f79e
12: #97a4f7
13: #c495f0
14: #68f2e0
15: #ffffff
foreground: #f7f7f7
background: #0e100a
cursor: #f7f7f7

kimber
0: #222222
1: #c88c8c
2: #99c899
3: #d8b56d
4: #537c9c
5: #86cacd
6: #78b4b4
7: #dedee7
8: #644646
9: #c88c8c
10: #99c899
11: #d8b56d
12: #537c9c
13: #86cacd
14: #78b4b4
15: #ffffe6
foreground: #dedee7
background: #222222
cursor: #dedee7

later-this-evening
0: #2b2b2b
1: #d45a60
2: #afba67
3: #e5d289
4: #a0bad6
5: #c092d6
6: #91bfb7
7: #3c3d3d
8: #454747
9: #d3232f
10: #aabb39
11: #e5be39
12: #6699d6
13: #ab53d6
14: #5fc0ae
15: #c1c2c2
foreground: #959595
background: #222222
cursor: #959595

lavandula
0: #230046
1: #7d1625
2: #337e6f
3: #7f6f49
4: #4f4a7f
5: #5a3f7f
6: #58777f
7: #736e7d
8: #372d46
9: #e05167
10: #52e0c4
11: #e0c386
12: #8e87e0
13: #a776e0
14: #9ad4e0
15: #8c91fa
foreground: #736e7d
background: #050014
cursor: #736e7d

liquid-carbon
0: #000000
1: #ff3030
2: #559a70
3: #ccac00
4: #0099cc
5: #cc69c8
6: #7ac4cc
7: #bccccc
8: #000000
9: #ff3030
10: #559a70
11: #ccac00
12: #0099cc
13: #cc69c8
14: #7ac4cc
15: #bccccc
foreground: #afc2c2
background: #303030
cursor: #afc2c2

liquid-carbon-transparent
0: #000000
1: #ff3030
2: #559a70
3: #ccac00
4: #0099cc
5: #cc69c8
6: #7ac4cc
7: #bccccc
8: #000000
9: #ff3030
10: #559a70
11: #ccac00
12: #0099cc
13: #cc69c8
14: #7ac4cc
15: #bccccc
foreground: #afc2c2
background: #000000
cursor: #afc2c2

london-tube
0: #231f20
1: #ee2e24
2: #00853e
3: #ffd204
4: #009ddc
5: #98005d
6: #85cebc
7: #d9d8d8
8: #737171
9: #ee2e24
10: #00853e
11: #ffd204
12: #009ddc
13: #98005d
14: #85cebc
15: #ffffff
foreground: #d9d8d8
background: #231f20
cursor: #d9d8d8

macintosh
0: #000000
1: #dd0907
2: #1fb714
3: #fbf305
4: #0000d3
5: #4700a5
6: #02abea
7: #c0c0c0
8: #808080
9: #dd0907
10: #1fb714
11: #fbf305
12: #0000d3
13: #4700a5
14: #02abea
15: #ffffff
foreground: #c0c0c0
background: #000000
cursor: #c0c0c0

maia
0: #232423
1: #ba2922
2: #7e807e
3: #4c4f4d
4: #16a085
5: #43746a
6: #00cccc
7: #e0e0e0
8: #282928
9: #cc372c
10: #8d8f8d
11: #4e524f
12: #13bf9d
13: #487d72
14: #00d1d1
15: #e8e8e8
foreground: #fdf6e3
background: #272827
cursor: #16a085

man-page
0: #000000
1: #cc0000
2: #00a600
3: #999900
4: #0000b2
5: #b200b2
6: #00a6b2
7: #cccccc
8: #666666
9: #e50000
10: #00d900
11: #e5e500
12: #0000ff
13: #e500e5
14: #00e5e5
15: #e5e5e5
foreground: #000000
background: #fef49c
cursor: #000000

mar
0: #000000
1: #b5407b
2: #7bb540
3: #b57b40
4: #407bb5
5: #7b40b5
6: #40b57b
7: #f8f8f8
8: #737373
9: #cd73a0
10: #a0cd73
11: #cda073
12: #73a0cd
13: #a073cd
14: #73cda0
15: #ffffff
foreground: #23476a
background: #ffffff
cursor: #23476a

marrakesh
0: #201602
1: #c35359
2: #18974e
3: #a88339
4: #477ca1
5: #8868b3
6: #75a738
7: #948e48
8: #6c6823
9: #c35359
10: #18974e
11: #a88339
12: #477ca1
13: #8868b3
14: #75a738
15: #faf0a5
foreground: #948e48
background: #201602
cursor: #948e48

materia
0: #263238
1: #ec5f67
2: #8bd649
3: #ffcc00
4: #89ddff
5: #82aaff
6: #80cbc4
7: #cdd3de
8: #707880
9: #ec5f67
10: #8bd649
11: #ffcc00
12: #89ddff
13: #82aaff
14: #80cbc4
15: #ffffff
foreground: #cdd3de
background: #263238
cursor: #cdd3de

material
0: #263238
1: #f07178
2: #c3e88d
3: #ffcb6b
4: #82aaff
5: #c792ea
6: #89ddff
7: #eeffff
8: #546e7a
9: #f07178
10: #c3e88d
11: #ffcb6b
12: #82aaff
13: #c792ea
14: #89ddff
15: #ffffff
foreground: #eeffff
background: #263238
cursor: #eeffff

material-dark
0: #212121
1: #b7141e
2: #457b23
3: #f5971d
4: #134eb2
5: #550087
6: #0e707c
7: #eeeeee
8: #424242
9: #e83a3f
10: #7aba39
11: #fee92e
12: #53a4f3
13: #a94dbb
14: #26bad1
15: #d8d8d8
foreground: #e4e4e4
background: #222221
cursor: #16aec9

material-darker
0: #212121
1: #f07178
2: #c3e88d
3: #ffcb6b
4: #82aaff
5: #c792ea
6: #89ddff
7: #eeffff
8: #4a4a4a
9: #f07178
10: #c3e88d
11: #ffcb6b
12: #82aaff
13: #c792ea
14: #89ddff
15: #ffffff
foreground: #eeffff
background: #212121
cursor: #eeffff

material-lighter
0: #fafafa
1: #ff5370
2: #91b859
3: #ffb62c
4: #6182b8
5: #7c4dff
6: #39adb5
7: #80cbc4
8: #ccd7da
9: #ff5370
10: #91b859
11: #ffb62c
12: #6182b8
13: #7c4dff
14: #39adb5
15: #ffffff
foreground: #80cbc4
background: #fafafa
cursor: #80cbc4

material-palenight
0: #292d3e
1: #f07178
2: #c3e88d
3: #ffcb6b
4: #82aaff
5: #c792ea
6: #89ddff
7: #959dcb
8: #676e95
9: #f07178
10: #c3e88d
11: #ffcb6b
12: #82aaff
13: #c792ea
14: #89ddff
15: #ffffff
foreground: #959dcb
background: #292d3e
cursor: #959dcb

material-vivid
0: #202124
1: #f44336
2: #00e676
3: #ffeb3b
4: #2196f3
5: #673ab7
6: #00bcd4
7: #80868b
8: #44464d
9: #f44336
10: #00e676
11: #ffeb3b
12: #2196f3
13: #673ab7
14: #00bcd4
15: #ffffff
foreground: #80868b
background: #202124
cursor: #80868b

mathias
0: #000000
1: #e52222
2: #a6e32d
3: #fc951e
4: #c48dff
5: #fa2573
6: #67d9f0
7: #f2f2f2
8: #555555
9: #ff5555
10: #55ff55
11: #ffff55
12: #5555ff
13: #ff55ff
14: #55ffff
15: #ffffff
foreground: #bbbbbb
background: #000000
cursor: #bbbbbb

medallion
0: #000000
1: #b64c00
2: #7c8b16
3: #d3bd26
4: #616bb0
5: #8c5a90
6: #916c25
7: #cac29a
8: #5e5219
9: #ff9149
10: #b2ca3b
11: #ffe54a
12: #acb8ff
13: #ffa0ff
14: #ffbc51
15: #fed698
foreground: #cac296
background: #1d1908
cursor: #cac296

mellow-purple
0: #1e0528
1: #00d9e9
2: #05cb0d
3: #955ae7
4: #550068
5: #8991bb
6: #b900b1
7: #ffeeff
8: #320f55
9: #00d9e9
10: #05cb0d
11: #955ae7
12: #550068
13: #8991bb
14: #b900b1
15: #f8c0ff
foreground: #ffeeff
background: #1e0528
cursor: #ffeeff

mexico-light
0: #f8f8f8
1: #ab4642
2: #538947
3: #f79a0e
4: #7cafc2
5: #96609e
6: #4b8093
7: #383838
8: #b8b8b8
9: #ab4642
10: #538947
11: #f79a0e
12: #7cafc2
13: #96609e
14: #4b8093
15: #181818
foreground: #383838
background: #f8f8f8
cursor: #383838

miramare
0: #e6d6ac
1: #e68183
2: #87af87
3: #d9bb80
4: #89beba
5: #d3a0bc
6: #87c095
7: #444444
8: #e6d6ac
9: #e68183
10: #87af87
11: #d9bb80
12: #89beba
13: #d3a0bc
14: #87c095
15: #444444
foreground: #e6d6ac
background: #2a2426
cursor: #d9bb80

misterioso
0: #000000
1: #ff4242
2: #74af68
3: #ffad29
4: #338f86
5: #9414e6
6: #23d7d7
7: #e1e1e0
8: #555555
9: #ff3242
10: #74cd68
11: #ffb929
12: #23d7d7
13: #ff37ff
14: #00ede1
15: #ffffff
foreground: #e1e1e0
background: #2d3743
cursor: #e1e1e0

miu
0: #000000
1: #b87a7a
2: #7ab87a
3: #b8b87a
4: #7a7ab8
5: #b87ab8
6: #7ab8b8
7: #d9d9d9
8: #262626
9: #dbbdbd
10: #bddbbd
11: #dbdbbd
12: #bdbddb
13: #dbbddb
14: #bddbdb
15: #ffffff
foreground: #d9e6f2
background: #0d1926
cursor: #d9e6f2

mocha
0: #3b3228
1: #cb6077
2: #beb55b
3: #f4bc87
4: #8ab3b5
5: #a89bb9
6: #7bbda4
7: #d0c8c6
8: #7e705a
9: #cb6077
10: #beb55b
11: #f4bc87
12: #8ab3b5
13: #a89bb9
14: #7bbda4
15: #f5eeeb
foreground: #d0c8c6
background: #3b3228
cursor: #d0c8c6

molokai
0: #1b1d1e
1: #7325fa
2: #23e298
3: #60d4df
4: #d08010
5: #ff0087
6: #d0a843
7: #bbbbbb
8: #555555
9: #9d66f6
10: #5fe0b1
11: #6df2ff
12: #ffaf00
13: #ff87af
14: #ffce51
15: #ffffff
foreground: #bbbbbb
background: #1b1d1e
cursor: #bbbbbb

mona-lisa
0: #351b0e
1: #9b291c
2: #636232
3: #c36e28
4: #515c5d
5: #9b1d29
6: #588056
7: #f7d75c
8: #874228
9: #ff4331
10: #b4b264
11: #ff9566
12: #9eb2b4
13: #ff5b6a
14: #8acd8f
15: #ffe598
foreground: #f7d66a
background: #120b0d
cursor: #f7d66a

mono-amber
0: #402500
1: #ff9400
2: #ff9400
3: #ff9400
4: #ff9400
5: #ff9400
6: #ff9400
7: #ff9400
8: #ff9400
9: #ff9400
10: #ff9400
11: #ff9400
12: #ff9400
13: #ff9400
14: #ff9400
15: #ff9400
foreground: #ff9400
background: #2b1900
cursor: #ff9400

mono-cyan
0: #003340
1: #00ccff
2: #00ccff
3: #00ccff
4: #00ccff
5: #00ccff
6: #00ccff
7: #00ccff
8: #00ccff
9: #00ccff
10: #00ccff
11: #00ccff
12: #00ccff
13: #00ccff
14: #00ccff
15: #00ccff
foreground: #00ccff
background: #00222b
cursor: #00ccff

mono-green
0: #034000
1: #0bff00
2: #0bff00
3: #0bff00
4: #0bff00
5: #0bff00
6: #0bff00
7: #0bff00
8: #0bff00
9: #0bff00
10: #0bff00
11: #0bff00
12: #0bff00
13: #0bff00
14: #0bff00
15: #0bff00
foreground: #0bff00
background: #022b00
cursor: #0bff00

mono-red
0: #401200
1: #ff3600
2: #ff3600
3: #ff3600
4: #ff3600
5: #ff3600
6: #ff3600
7: #ff3600
8: #ff3600
9: #ff3600
10: #ff3600
11: #ff3600
12: #ff3600
13: #ff3600
14: #ff3600
15: #ff3600
foreground: #ff3600
background: #2b0c00
cursor: #ff3600

mono-white
0: #3b3b3b
1: #fafafa
2: #fafafa
3: #fafafa
4: #fafafa
5: #fafafa
6: #fafafa
7: #fafafa
8: #fafafa
9: #fafafa
10: #fafafa
11: #fafafa
12: #fafafa
13: #fafafa
14: #fafafa
15: #fafafa
foreground: #fafafa
background: #262626
cursor: #fafafa

mono-yellow
0: #403500
1: #ffd300
2: #ffd300
3: #ffd300
4: #ffd300
5: #ffd300
6: #ffd300
7: #ffd300
8: #ffd300
9: #ffd300
10: #ffd300
11: #ffd300
12: #ffd300
13: #ffd300
14: #ffd300
15: #ffd300
foreground: #ffd300
background: #2b2400
cursor: #ffd300

monokai
0: #272822
1: #f92672
2: #a6e22e
3: #f4bf75
4: #66d9ef
5: #ae81ff
6: #a1efe4
7: #f8f8f2
8: #75715e
9: #f92672
10: #a6e22e
11: #f4bf75
12: #66d9ef
13: #ae81ff
14: #a1efe4
15: #f9f8f5
foreground: #f8f8f2
background: #272822
cursor: #f8f8f2

monokai-dark
0: #75715e
1: #f92672
2: #a6e22e
3: #f4bf75
4: #66d9ef
5: #ae81ff
6: #2aa198
7: #f9f8f5
8: #272822
9: #f92672
10: #a6e22e
11: #f4bf75
12: #66d9ef
13: #ae81ff
14: #2aa198
15: #f8f8f2
foreground: #f8f8f2
background: #272822
cursor: #f8f8f2

monokai-soda
0: #1a1a1a
1: #f4005f
2: #98e024
3: #fa8419
4: #9d65ff
5: #f4005f
6: #58d1eb
7: #c4c5b5
8: #625e4c
9: #f4005f
10: #98e024
11: #e0d561
12: #9d65ff
13: #f4005f
14: #58d1eb
15: #f6f6ef
foreground: #c4c5b5
background: #1a1a1a
cursor: #c4c5b5

mountaineer
0: #1d1f21
1: #cc6666
2: #b5bd68
3: #f0c674
4: #81a2be
5: #b294bb
6: #8abeb7
7: #c5c8c6
8: #969896
9: #cc6666
10: #b5bd68
11: #f0c674
12: #81a2be
13: #b294bb
14: #8abeb7
15: #ffffff
foreground: #f0f0f0
background: #050505
cursor: #b5bd68

mountaineer-grey
0: #1d1f21
1: #cc6666
2: #b5bd68
3: #f0c674
4: #81a2be
5: #b294bb
6: #8abeb7
7: #c5c8c6
8: #969896
9: #cc6666
10: #b5bd68
11: #f0c674
12: #81a2be
13: #b294bb
14: #8abeb7
15: #ffffff
foreground: #c0c0c0
background: #232323
cursor: #b5bd68

n0tch2k
0: #383838
1: #a95551
2: #666666
3: #a98051
4: #657d3e
5: #767676
6: #c9c9c9
7: #d0b8a3
8: #474747
9: #a97775
10: #8c8c8c
11: #a99175
12: #98bd5e
13: #a3a3a3
14: #dcdcdc
15: #d8c8bb
foreground: #a0a0a0
background: #222222
cursor: #a0a0a0

nebula
0: #22273b
1: #777abc
2: #6562a8
3: #4f9062
4: #4d6bb6
5: #716cae
6: #226f68
7: #a4a6a9
8: #6e6f72
9: #777abc
10: #6562a8
11: #4f9062
12: #4d6bb6
13: #716cae
14: #226f68
15: #8dbdaa
foreground: #a4a6a9
background: #22273b
cursor: #a4a6a9

neon-night
0: #20242d
1: #ff8e8e
2: #7efdd0
3: #fcad3f
4: #69b4f9
5: #dd92f6
6: #8ce8ff
7: #c9cccd
8: #20242d
9: #ff8e8e
10: #7efdd0
11: #fcad3f
12: #69b4f9
13: #dd92f6
14: #8ce8ff
15: #c9cccd
foreground: #c7c8ff
background: #20242d
cursor: #c7c8ff

neopolitan
0: #000000
1: #800000
2: #61ce3c
3: #fbde2d
4: #253b76
5: #ff0080
6: #8da6ce
7: #f8f8f8
8: #000000
9: #800000
10: #61ce3c
11: #fbde2d
12: #253b76
13: #ff0080
14: #8da6ce
15: #f8f8f8
foreground: #ffffff
background: #271f19
cursor: #ffffff

nep
0: #000000
1: #dd6f00
2: #00dd6f
3: #6fdd00
4: #6f00dd
5: #dd006f
6: #006fdd
7: #f2f2f2
8: #7d7d7d
9: #ffb974
10: #74ffb9
11: #b9ff74
12: #b974ff
13: #ff74b9
14: #74b9ff
15: #ffffff
foreground: #23476a
background: #758480
cursor: #23476a

neutron
0: #23252b
1: #b54036
2: #5ab977
3: #deb566
4: #6a7c93
5: #a4799d
6: #3f94a8
7: #e6e8ef
8: #23252b
9: #b54036
10: #5ab977
11: #deb566
12: #6a7c93
13: #a4799d
14: #3f94a8
15: #ebedf2
foreground: #e6e8ef
background: #1c1e22
cursor: #e6e8ef

nightfly
0: #1d3b53
1: #fc514e
2: #a1cd5e
3: #e7d37a
4: #82aaff
5: #c792ea
6: #7fdbca
7: #a1aab8
8: #7c8f8f
9: #ff5874
10: #21c7a8
11: #ecc48d
12: #82aaff
13: #ae81ff
14: #7fdbca
15: #d6deeb
foreground: #c3ccdc
background: #011627
cursor: #82aaff

nightlion-v1
0: #4c4c4c
1: #bb0000
2: #5fde8f
3: #f3f167
4: #276bd8
5: #bb00bb
6: #00dadf
7: #bbbbbb
8: #555555
9: #ff5555
10: #55ff55
11: #ffff55
12: #5555ff
13: #ff55ff
14: #55ffff
15: #ffffff
foreground: #bbbbbb
background: #000000
cursor: #bbbbbb

nightlion-v2
0: #4c4c4c
1: #bb0000
2: #04f623
3: #f3f167
4: #64d0f0
5: #ce6fdb
6: #00dadf
7: #bbbbbb
8: #555555
9: #ff5555
10: #7df71d
11: #ffff55
12: #62cbe8
13: #ff9bf5
14: #00ccd8
15: #ffffff
foreground: #bbbbbb
background: #171717
cursor: #bbbbbb

nighty
0: #373d48
1: #9b3e46
2: #095b32
3: #808020
4: #1d3e6f
5: #823065
6: #3a7458
7: #828282
8: #5c6370
9: #d0555f
10: #119955
11: #dfe048
12: #4674b8
13: #ed86c9
14: #70d2a4
15: #dfdfdf
foreground: #dfdfdf
background: #2f2f2f
cursor: #dfdfdf

nord
0: #2e3440
1: #bf616a
2: #a3be8c
3: #ebcb8b
4: #81a1c1
5: #b48ead
6: #88c0d0
7: #e5e9f0
8: #4c566a
9: #bf616a
10: #a3be8c
11: #ebcb8b
12: #81a1c1
13: #b48ead
14: #88c0d0
15: #8fbcbb
foreground: #e5e9f0
background: #2e3440
cursor: #e5e9f0

nord-alt
0: #2e3440
1: #3b4252
2: #434c5e
3: #4c566a
4: #d8dee9
5: #e5e9f0
6: #eceff4
7: #8fbcbb
8: #bf616a
9: #d08770
10: #ebcb8b
11: #a3be8c
12: #88c0d0
13: #81a1c1
14: #b48ead
15: #5e81ac
foreground: #8fbcbb
background: #2e3440
cursor: #8fbcbb

nord-light
0: #353535
1: #e64569
2: #89d287
3: #dab752
4: #439ecf
5: #d961dc
6: #64aaaf
7: #b3b3b3
8: #535353
9: #e4859a
10: #a2cca1
11: #e1e387
12: #6fbbe2
13: #e586e7
14: #96dcda
15: #dedede
foreground: #004f7c
background: #ebeaf2
cursor: #004f7c

nova
0: #3c4c55
1: #83afe5
2: #7fc1ca
3: #a8ce93
4: #83afe5
5: #9a93e1
6: #f2c38f
7: #c5d4dd
8: #899ba6
9: #83afe5
10: #7fc1ca
11: #a8ce93
12: #83afe5
13: #9a93e1
14: #f2c38f
15: #556873
foreground: #c5d4dd
background: #3c4c55
cursor: #c5d4dd

novel
0: #000000
1: #cc0000
2: #009600
3: #d06b00
4: #0000cc
5: #cc00cc
6: #0087cc
7: #cccccc
8: #808080
9: #cc0000
10: #009600
11: #d06b00
12: #0000cc
13: #cc00cc
14: #0087cc
15: #ffffff
foreground: #3b2322
background: #dfdbc3
cursor: #3b2322

obsidian
0: #000000
1: #a60001
2: #00bb00
3: #fecd22
4: #3a9bdb
5: #bb00bb
6: #00bbbb
7: #bbbbbb
8: #555555
9: #ff0003
10: #93c863
11: #fef874
12: #a1d7ff
13: #ff55ff
14: #55ffff
15: #ffffff
foreground: #cdcdcd
background: #283033
cursor: #cdcdcd

ocean
0: #2b303b
1: #bf616a
2: #a3be8c
3: #ebcb8b
4: #8fa1b3
5: #b48ead
6: #96b5b4
7: #c0c5ce
8: #65737e
9: #bf616a
10: #a3be8c
11: #ebcb8b
12: #8fa1b3
13: #b48ead
14: #96b5b4
15: #eff1f5
foreground: #c0c5ce
background: #2b303b
cursor: #c0c5ce

ocean-dark
0: #4f4f4f
1: #af4b57
2: #afd383
3: #e5c079
4: #7d90a4
5: #a4799d
6: #85a6a5
7: #eeedee
8: #7b7b7b
9: #af4b57
10: #ceffab
11: #fffecc
12: #b5dcfe
13: #fb9bfe
14: #dfdffd
15: #fefffe
foreground: #979cac
background: #1c1f27
cursor: #979cac

oceanic-material
0: #000000
1: #ee2a29
2: #3fa33f
3: #fee92e
4: #1d80ef
5: #8800a0
6: #16aec9
7: #a4a4a4
8: #767676
9: #dc5b60
10: #70be71
11: #fef063
12: #53a4f3
13: #a94dbb
14: #42c6d9
15: #fffefe
foreground: #c1c8d6
background: #1c262b
cursor: #b2b8c3

oceanic-next
0: #121c21
1: #e44754
2: #89bd82
3: #f7bd51
4: #5486c0
5: #b77eb8
6: #50a5a4
7: #ffffff
8: #52606b
9: #e44754
10: #89bd82
11: #f7bd51
12: #5486c0
13: #b77eb8
14: #50a5a4
15: #ffffff
foreground: #b3b8c3
background: #121b21
cursor: #b3b8c3

oceanicnext
0: #1b2b34
1: #ec5f67
2: #99c794
3: #fac863
4: #6699cc
5: #c594c5
6: #5fb3b3
7: #c0c5ce
8: #65737e
9: #ec5f67
10: #99c794
11: #fac863
12: #6699cc
13: #c594c5
14: #5fb3b3
15: #d8dee9
foreground: #c0c5ce
background: #1b2b34
cursor: #c0c5ce

ollie
0: #000000
1: #ac2e31
2: #31ac61
3: #ac4300
4: #2d57ac
5: #b08528
6: #1fa6ac
7: #8a8eac
8: #5b3725
9: #ff3d48
10: #3bff99
11: #ff5e1e
12: #4488ff
13: #ffc21d
14: #1ffaff
15: #5b6ea7
foreground: #8a8dae
background: #222125
cursor: #8a8dae

one-dark
0: #000000
1: #e06c75
2: #98c379
3: #d19a66
4: #61afef
5: #c678dd
6: #56b6c2
7: #abb2bf
8: #5c6370
9: #e06c75
10: #98c379
11: #d19a66
12: #61afef
13: #c678dd
14: #56b6c2
15: #fffefe
foreground: #5c6370
background: #1e2127
cursor: #5c6370

one-half-black
0: #282c34
1: #e06c75
2: #98c379
3: #e5c07b
4: #61afef
5: #c678dd
6: #56b6c2
7: #dcdfe4
8: #282c34
9: #e06c75
10: #98c379
11: #e5c07b
12: #61afef
13: #c678dd
14: #56b6c2
15: #dcdfe4
foreground: #dcdfe4
background: #000000
cursor: #dcdfe4

one-half-light
0: #383a42
1: #e45649
2: #40a14f
3: #c18401
4: #0184bc
5: #a626a4
6: #0997b3
7: #fafafa
8: #383a42
9: #e45649
10: #40a14f
11: #c18401
12: #0184bc
13: #a626a4
14: #0997b3
15: #fafafa
foreground: #383a42
background: #fafafa
cursor: #383a42

one-light
0: #fafafa
1: #ca1243
2: #50a14f
3: #c18401
4: #4078f2
5: #a626a4
6: #0184bc
7: #383a42
8: #a0a1a7
9: #ca1243
10: #50a14f
11: #c18401
12: #4078f2
13: #a626a4
14: #0184bc
15: #090a0b
foreground: #383a42
background: #fafafa
cursor: #383a42

onedark
0: #282c34
1: #e06c75
2: #98c379
3: #e5c07b
4: #61afef
5: #c678dd
6: #56b6c2
7: #abb2bf
8: #545862
9: #e06c75
10: #98c379
11: #e5c07b
12: #61afef
13: #c678dd
14: #56b6c2
15: #c8ccd4
foreground: #abb2bf
background: #282c34
cursor: #abb2bf

orbital
0: #000000
1: #5f5f5f
2: #bcbcbc
3: #d7af87
4: #5f87d7
5: #87afd7
6: #0087d7
7: #0000d7
8: #262626
9: #949494
10: #ffd7af
11: #af875f
12: #5f87af
13: #5fafff
14: #005faf
15: #0000d7
foreground: #e4e4e4
background: #000000
cursor: #5fafff

outrun-dark
0: #00002a
1: #ff4242
2: #59f176
3: #f3e877
4: #66b0ff
5: #f10596
6: #0ef0f0
7: #d0d0fa
8: #50507a
9: #ff4242
10: #59f176
11: #f3e877
12: #66b0ff
13: #f10596
14: #0ef0f0
15: #f5f5ff
foreground: #d0d0fa
background: #00002a
cursor: #d0d0fa

pali
0: #0a0a0a
1: #ab8f74
2: #74ab8f
3: #8fab74
4: #8f74ab
5: #ab748f
6: #748fab
7: #f2f2f2
8: #5d5d5d
9: #ff1d62
10: #9cc3af
11: #ffd00a
12: #af9cc3
13: #ff1d62
14: #4bb8fd
15: #a020f0
foreground: #d9e6f2
background: #232e37
cursor: #d9e6f2

palmtree
0: #282a36
1: #f37f97
2: #5adecd
3: #f2a272
4: #8897f4
5: #c574dd
6: #79e6f3
7: #fdfdfd
8: #666979
9: #ff4971
10: #18e3c8
11: #ff8037
12: #556fff
13: #b043d1
14: #3fdcee
15: #bebec1
foreground: #b043d1
background: #282a36
cursor: #3fdcee

papercolor-dark
0: #1c1c1c
1: #585858
2: #af87d7
3: #afd700
4: #ff5faf
5: #00afaf
6: #ffaf00
7: #808080
8: #d7af5f
9: #585858
10: #af87d7
11: #afd700
12: #ff5faf
13: #00afaf
14: #ffaf00
15: #d0d0d0
foreground: #808080
background: #1c1c1c
cursor: #808080

papercolor-light
0: #eeeeee
1: #bcbcbc
2: #8700af
3: #d70087
4: #d75f00
5: #005faf
6: #d75f00
7: #444444
8: #5f8700
9: #bcbcbc
10: #8700af
11: #d70087
12: #d75f00
13: #005faf
14: #d75f00
15: #878787
foreground: #444444
background: #eeeeee
cursor: #444444

paraiso
0: #2f1e2e
1: #ef6155
2: #48b685
3: #fec418
4: #06b6ef
5: #815ba4
6: #5bc4bf
7: #a39e9b
8: #776e71
9: #ef6155
10: #48b685
11: #fec418
12: #06b6ef
13: #815ba4
14: #5bc4bf
15: #e7e9db
foreground: #a39e9b
background: #2f1e2e
cursor: #a39e9b

paraiso-dark
0: #2f1e2e
1: #ef6155
2: #48b685
3: #fec418
4: #06b6ef
5: #815ba4
6: #5bc4bf
7: #a39e9b
8: #776e71
9: #ef6155
10: #48b685
11: #fec418
12: #06b6ef
13: #815ba4
14: #5bc4bf
15: #e7e9db
foreground: #a39e9b
background: #2f1e2e
cursor: #a39e9b

pasque
0: #271c3a
1: #a92258
2: #c6914b
3: #804ead
4: #8e7dc6
5: #953b9d
6: #7263aa
7: #dedcdf
8: #5d5766
9: #a92258
10: #c6914b
11: #804ead
12: #8e7dc6
13: #953b9d
14: #7263aa
15: #bbaadd
foreground: #dedcdf
background: #271c3a
cursor: #dedcdf

paul-millr
0: #2a2a2a
1: #ff0000
2: #79ff0f
3: #d3bf00
4: #396bd7
5: #b449be
6: #66ccff
7: #bbbbbb
8: #666666
9: #ff0080
10: #66ff66
11: #f3d64e
12: #709aed
13: #db67e6
14: #7adff2
15: #ffffff
foreground: #f2f2f2
background: #000000
cursor: #f2f2f2

pencil-dark
0: #212121
1: #c30771
2: #10a778
3: #a89c14
4: #008ec4
5: #523c79
6: #20a5ba
7: #d9d9d9
8: #424242
9: #fb007a
10: #5fd7af
11: #f3e430
12: #20bbfc
13: #6855de
14: #4fb8cc
15: #f1f1f1
foreground: #f1f1f1
background: #212121
cursor: #f1f1f1

pencil-light
0: #212121
1: #c30771
2: #10a778
3: #a89c14
4: #008ec4
5: #523c79
6: #20a5ba
7: #d9d9d9
8: #424242
9: #fb007a
10: #5fd7af
11: #f3e430
12: #20bbfc
13: #6855de
14: #4fb8cc
15: #f1f1f1
foreground: #424242
background: #f1f1f1
cursor: #424242

peppermint
0: #353535
1: #e64569
2: #89d287
3: #dab752
4: #439ecf
5: #d961dc
6: #64aaaf
7: #b3b3b3
8: #535353
9: #e4859a
10: #a2cca1
11: #e1e387
12: #6fbbe2
13: #e586e7
14: #96dcda
15: #dedede
foreground: #c7c7c7
background: #000000
cursor: #bbbbbb

phd
0: #061229
1: #d07346
2: #99bf52
3: #fbd461
4: #5299bf
5: #9989cc
6: #72b9bf
7: #b8bbc2
8: #717885
9: #d07346
10: #99bf52
11: #fbd461
12: #5299bf
13: #9989cc
14: #72b9bf
15: #ffffff
foreground: #b8bbc2
background: #061229
cursor: #b8bbc2

piatto-light
0: #414141
1: #b23670
2: #66781d
3: #cc6e33
4: #3b5ea7
5: #a353b2
6: #66781d
7: #ffffff
8: #3e3e3e
9: #da3365
10: #829428
11: #cc6e33
12: #3b5ea7
13: #a353b2
14: #829428
15: #f1f1f1
foreground: #414141
background: #ffffff
cursor: #5e76c7

pico
0: #000000
1: #ff004d
2: #00e756
3: #fff024
4: #83769c
5: #ff77a8
6: #29adff
7: #5f574f
8: #008751
9: #ff004d
10: #00e756
11: #fff024
12: #83769c
13: #ff77a8
14: #29adff
15: #fff1e8
foreground: #5f574f
background: #000000
cursor: #5f574f

pnevma
0: #2f2e2d
1: #a36666
2: #90a57d
3: #d7af87
4: #7fa5bd
5: #c79ec4
6: #8adbb4
7: #d0d0d0
8: #4a4845
9: #d78787
10: #afbea2
11: #e4c9af
12: #a1bdce
13: #d7beda
14: #b1e7dd
15: #efefef
foreground: #d0d0d0
background: #1c1c1c
cursor: #d0d0d0

pop
0: #000000
1: #eb008a
2: #37b349
3: #f8ca12
4: #0e5a94
5: #b31e8d
6: #00aabb
7: #d0d0d0
8: #505050
9: #eb008a
10: #37b349
11: #f8ca12
12: #0e5a94
13: #b31e8d
14: #00aabb
15: #ffffff
foreground: #d0d0d0
background: #000000
cursor: #d0d0d0

porple
0: #292c36
1: #f84547
2: #95c76f
3: #efa16b
4: #8485ce
5: #b74989
6: #64878f
7: #d8d8d8
8: #65568a
9: #f84547
10: #95c76f
11: #efa16b
12: #8485ce
13: #b74989
14: #64878f
15: #f8f8f8
foreground: #d8d8d8
background: #292c36
cursor: #d8d8d8

pro
0: #000000
1: #990000
2: #00a600
3: #999900
4: #2009db
5: #b200b2
6: #00a6b2
7: #bfbfbf
8: #666666
9: #e50000
10: #00d900
11: #e5e500
12: #0000ff
13: #e500e5
14: #00e5e5
15: #e5e5e5
foreground: #f2f2f2
background: #000000
cursor: #f2f2f2

railscasts
0: #2b2b2b
1: #da4939
2: #a5c261
3: #ffc66d
4: #6d9cbe
5: #b6b3eb
6: #519f50
7: #e6e1dc
8: #5a647e
9: #da4939
10: #a5c261
11: #ffc66d
12: #6d9cbe
13: #b6b3eb
14: #519f50
15: #f9f7f3
foreground: #e6e1dc
background: #2b2b2b
cursor: #e6e1dc

rebecca
0: #292a44
1: #a0a0c5
2: #6dfedf
3: #ae81ff
4: #2de0a7
5: #7aa5ff
6: #8eaee0
7: #f1eff8
8: #666699
9: #a0a0c5
10: #6dfedf
11: #ae81ff
12: #2de0a7
13: #7aa5ff
14: #8eaee0
15: #53495d
foreground: #f1eff8
background: #292a44
cursor: #f1eff8

red-alert
0: #000000
1: #d62e4e
2: #71be6b
3: #beb86b
4: #489bee
5: #e979d7
6: #6bbeb8
7: #d6d6d6
8: #262626
9: #e02553
10: #aff08c
11: #dfddb7
12: #65aaf1
13: #ddb7df
14: #b7dfdd
15: #ffffff
foreground: #ffffff
background: #762423
cursor: #ffffff

red-sands
0: #000000
1: #ff3f00
2: #00bb00
3: #e7b000
4: #0072ff
5: #bb00bb
6: #00bbbb
7: #bbbbbb
8: #555555
9: #bb0000
10: #00bb00
11: #e7b000
12: #0072ae
13: #ff55ff
14: #55ffff
15: #ffffff
foreground: #d7c9a7
background: #7a251e
cursor: #d7c9a7

relaxed-afterglow
0: #151515
1: #bc5653
2: #909d63
3: #ebc17a
4: #6a8799
5: #b06698
6: #c9dfff
7: #d9d9d9
8: #636363
9: #bc5653
10: #a0ac77
11: #ebc17a
12: #7eaac7
13: #b06698
14: #acbbd0
15: #f7f7f7
foreground: #d9d9d9
background: #353a44
cursor: #d9d9d9

renault-style-light
0: #000000
1: #da4839
2: #509f50
3: #ffd249
4: #46657d
5: #cfcfff
6: #87c1f1
7: #ffffff
8: #323232
9: #ff7b6a
10: #83d082
11: #ffff7b
12: #9fcef0
13: #ffffff
14: #a4d4f8
15: #ffffff
foreground: #e9cb7b
background: #3a3a3a
cursor: #7f7f7f

rippedcasts
0: #000000
1: #cdaf95
2: #a8ff60
3: #bfbb1f
4: #75a5b0
5: #ff73fd
6: #5a647e
7: #bfbfbf
8: #666666
9: #eecbad
10: #bcee68
11: #e5e500
12: #86bdc9
13: #e500e5
14: #8c9bc4
15: #e5e5e5
foreground: #ffffff
background: #2b2b2b
cursor: #ffffff

rose-pine
0: #26233a
1: #eb6f92
2: #31748f
3: #f6c177
4: #9ccfd8
5: #c4a7e7
6: #ebbcba
7: #e0def4
8: #6e6a86
9: #eb6f92
10: #31748f
11: #f6c177
12: #9ccfd8
13: #c4a7e7
14: #ebbcba
15: #e0def4
foreground: #e0def4
background: #191724
cursor: #555169

rose-pine-dawn
0: #f2e9de
1: #b4637a
2: #286983
3: #ea9d34
4: #56949f
5: #907aa9
6: #d7827e
7: #575279
8: #6e6a86
9: #b4637a
10: #286983
11: #ea9d34
12: #56949f
13: #907aa9
14: #d7827e
15: #575279
foreground: #575279
background: #faf4ed
cursor: #9893a5

rose-pine-moon
0: #393552
1: #eb6f92
2: #3e8fb0
3: #f6c177
4: #9ccfd8
5: #c4a7e7
6: #ea9a97
7: #e0def4
8: #817c9c
9: #eb6f92
10: #3e8fb0
11: #f6c177
12: #9ccfd8
13: #c4a7e7
14: #ea9a97
15: #e0def4
foreground: #e0def4
background: #232136
cursor: #59546d

royal
0: #241f2b
1: #91284c
2: #23801c
3: #b49d27
4: #6580b0
5: #674d96
6: #8aaabe
7: #524966
8: #312d3d
9: #d5356c
10: #2cd946
11: #fde83b
12: #90baf9
13: #a479e3
14: #acd4eb
15: #9e8cbd
foreground: #514968
background: #100815
cursor: #514968

sagelight
0: #f8f8f8
1: #fa8480
2: #a0d2c8
3: #ffdc61
4: #a0a7d2
5: #c8a0d2
6: #a2d6f5
7: #383838
8: #b8b8b8
9: #fa8480
10: #a0d2c8
11: #ffdc61
12: #a0a7d2
13: #c8a0d2
14: #a2d6f5
15: #181818
foreground: #383838
background: #f8f8f8
cursor: #383838

sandcastle
0: #282c34
1: #83a598
2: #528b8b
3: #a07e3b
4: #83a598
5: #d75f5f
6: #83a598
7: #a89984
8: #665c54
9: #83a598
10: #528b8b
11: #a07e3b
12: #83a598
13: #d75f5f
14: #83a598
15: #fdf4c1
foreground: #a89984
background: #282c34
cursor: #a89984

sat
0: #000000
1: #dd0007
2: #07dd00
3: #ddd600
4: #0007dd
5: #d600dd
6: #00ddd6
7: #f2f2f2
8: #7d7d7d
9: #ff7478
10: #78ff74
11: #fffa74
12: #7478ff
13: #fa74ff
14: #74fffa
15: #ffffff
foreground: #23476a
background: #758480
cursor: #23476a

sea-shells
0: #17384c
1: #d15123
2: #027c9b
3: #fca02f
4: #1e4950
5: #68d4f1
6: #50a3b5
7: #deb88d
8: #434b53
9: #d48678
10: #628d98
11: #fdd39f
12: #1bbcdd
13: #bbe3ee
14: #87acb4
15: #fee4ce
foreground: #deb88d
background: #09141b
cursor: #deb88d

seafoam-pastel
0: #757575
1: #825d4d
2: #728c62
3: #ada16d
4: #4d7b82
5: #8a7267
6: #729494
7: #e0e0e0
8: #8a8a8a
9: #cf937a
10: #98d9aa
11: #fae79d
12: #7ac3cf
13: #d6b2a1
14: #ade0e0
15: #e0e0e0
foreground: #d4e7d4
background: #243435
cursor: #d4e7d4

selenized-black
0: #252525
1: #ed4a46
2: #70b433
3: #dbb32d
4: #368aeb
5: #eb6eb7
6: #3fc5b7
7: #777777
8: #3b3b3b
9: #ff5e56
10: #83c746
11: #efc541
12: #4f9cfe
13: #ff81ca
14: #56d8c9
15: #dedede
foreground: #b9b9b9
background: #181818
cursor: #b9b9b9

selenized-dark
0: #184956
1: #fa5750
2: #75b938
3: #dbb32d
4: #4695f7
5: #f275be
6: #41c7b9
7: #72898f
8: #2d5b69
9: #ff665c
10: #84c747
11: #ebc13d
12: #58a3ff
13: #ff84cd
14: #53d6c7
15: #cad8d9
foreground: #adbcbc
background: #103c48
cursor: #adbcbc

selenized-light
0: #ece3cc
1: #d2212d
2: #489100
3: #ad8900
4: #0072d4
5: #ca4898
6: #009c8f
7: #909995
8: #d5cdb6
9: #cc1729
10: #428b00
11: #a78300
12: #006dce
13: #c44392
14: #00978a
15: #3a4d53
foreground: #53676d
background: #fbf3db
cursor: #53676d

selenized-white
0: #ebebeb
1: #d6000c
2: #1d9700
3: #c49700
4: #0064e4
5: #dd0f9d
6: #00ad9c
7: #878787
8: #cdcdcd
9: #bf0000
10: #008400
11: #af8500
12: #0054cf
13: #c7008b
14: #009a8a
15: #282828
foreground: #474747
background: #ffffff
cursor: #474747

seoul256
0: #4e4e4e
1: #d68787
2: #5f865f
3: #d8af5f
4: #85add4
5: #d7afaf
6: #87afaf
7: #d0d0d0
8: #626262
9: #d75f87
10: #87af87
11: #ffd787
12: #add4fb
13: #ffafaf
14: #87d7d7
15: #e4e4e4
foreground: #d0d0d0
background: #3a3a3a
cursor: #d0d0d0

seti
0: #151718
1: #cd3f45
2: #9fca56
3: #e6cd69
4: #55b5db
5: #a074c4
6: #55dbbe
7: #d6d6d6
8: #41535b
9: #cd3f45
10: #9fca56
11: #e6cd69
12: #55b5db
13: #a074c4
14: #55dbbe
15: #ffffff
foreground: #d6d6d6
background: #151718
cursor: #d6d6d6

seti-ui
0: #151718
1: #cd3f45
2: #9fca56
3: #e6cd69
4: #55b5db
5: #a074c4
6: #55dbbe
7: #d6d6d6
8: #41535b
9: #cd3f45
10: #9fca56
11: #e6cd69
12: #55b5db
13: #a074c4
14: #55dbbe
15: #ffffff
foreground: #d6d6d6
background: #151718
cursor: #d6d6d6

shaman
0: #012026
1: #b2302d
2: #00a941
3: #5e8baa
4: #449a86
5: #00599d
6: #5d7e19
7: #405555
8: #384451
9: #ff4242
10: #2aea5e
11: #8ed4fd
12: #61d5ba
13: #1298ff
14: #98d028
15: #58fbd6
foreground: #405555
background: #001015
cursor: #405555

shapeshifter
0: #f9f9f9
1: #e92f2f
2: #0ed839
3: #dddd13
4: #3b48e3
5: #f996e2
6: #23edda
7: #102015
8: #555555
9: #e92f2f
10: #0ed839
11: #dddd13
12: #3b48e3
13: #f996e2
14: #23edda
15: #000000
foreground: #102015
background: #f9f9f9
cursor: #102015

shel
0: #2c2423
1: #ab2463
2: #6ca323
3: #ab6423
4: #2c64a2
5: #6c24a2
6: #2ca363
7: #918988
8: #918988
9: #f588b9
10: #c2ee86
11: #f5ba86
12: #8fbaec
13: #c288ec
14: #8feeb9
15: #f5eeec
foreground: #4882cd
background: #2a201f
cursor: #4882cd

sierra
0: #0e0e04
1: #515a45
2: #68694f
3: #7f7f60
4: #989876
5: #897c5b
6: #a18e60
7: #bb7774
8: #a85e5d
9: #475a2e
10: #676938
11: #7f7f41
12: #98984e
13: #897645
14: #a17140
15: #c9cbac
foreground: #cacbb9
background: #1c1a14
cursor: #cacbb9

silk-dark
0: #0e3c46
1: #fb6953
2: #73d8ad
3: #fce380
4: #46bddd
5: #756b8a
6: #3fb2b9
7: #c7dbdd
8: #587073
9: #fb6953
10: #73d8ad
11: #fce380
12: #46bddd
13: #756b8a
14: #3fb2b9
15: #d2faff
foreground: #c7dbdd
background: #0e3c46
cursor: #c7dbdd

silk-light
0: #e9f1ef
1: #cf432e
2: #6ca38c
3: #cfad25
4: #39aac9
5: #6e6582
6: #329ca2
7: #385156
8: #5c787b
9: #cf432e
10: #6ca38c
11: #cfad25
12: #39aac9
13: #6e6582
14: #329ca2
15: #d2faff
foreground: #385156
background: #e9f1ef
cursor: #385156

slate
0: #222222
1: #e2a8bf
2: #81d778
3: #c4c9c0
4: #264b49
5: #a481d3
6: #15ab9c
7: #02c5e0
8: #ffffff
9: #ffcdd9
10: #beffa8
11: #d0ccca
12: #7ab0d2
13: #c5a7d9
14: #8cdfe0
15: #e0e0e0
foreground: #35b1d2
background: #222222
cursor: #35b1d2

smyck
0: #000000
1: #c75646
2: #8eb33b
3: #d0b03c
4: #72b3cc
5: #c8a0d1
6: #218693
7: #b0b0b0
8: #5d5d5d
9: #e09690
10: #cdee69
11: #ffe377
12: #9cd9f0
13: #fbb1f9
14: #77dfd8
15: #f7f7f7
foreground: #f7f7f7
background: #242424
cursor: #f7f7f7

snazzy
0: #282a36
1: #ff5c57
2: #5af78e
3: #f3f99d
4: #57c7ff
5: #ff6ac1
6: #9aedfe
7: #e2e4e5
8: #78787e
9: #ff5c57
10: #5af78e
11: #f3f99d
12: #57c7ff
13: #ff6ac1
14: #9aedfe
15: #f1f1f0
foreground: #e2e4e5
background: #282a36
cursor: #e2e4e5

snow-dark
0: #2c2d30
1: #be868c
2: #7f9d77
3: #ab916d
4: #759abd
5: #a88cb3
6: #5da19f
7: #afb7c0
8: #363a3e
9: #be868c
10: #7f9d77
11: #ab916d
12: #759abd
13: #a88cb3
14: #5da19f
15: #cbd2d9
foreground: #afb7c0
background: #2c2d30
cursor: #cbd2d9

snow-light
0: #fbffff
1: #ae5865
2: #4d7f43
3: #906c33
4: #2b7ab2
5: #8f63a2
6: #008483
7: #535c65
8: #6d7782
9: #ae5865
10: #4d7f43
11: #906c33
12: #2b7ab2
13: #8f63a2
14: #008483
15: #434951
foreground: #535c65
background: #fbffff
cursor: #434951

soft-server
0: #000000
1: #a2686a
2: #9aa56a
3: #a3906a
4: #6b8fa3
5: #6a71a3
6: #6ba58f
7: #99a3a2
8: #666c6c
9: #dd5c60
10: #bfdf55
11: #deb360
12: #62b1df
13: #606edf
14: #64e39c
15: #d2e0de
foreground: #99a3a2
background: #242626
cursor: #99a3a2

solar-flare
0: #18262f
1: #ef5253
2: #7cc844
3: #e4b51c
4: #33b5e1
5: #a363d5
6: #52cbb0
7: #a6afb8
8: #667581
9: #ef5253
10: #7cc844
11: #e4b51c
12: #33b5e1
13: #a363d5
14: #52cbb0
15: #f5f7fa
foreground: #a6afb8
background: #18262f
cursor: #a6afb8

solarflare
0: #18262f
1: #ef5253
2: #7cc844
3: #e4b51c
4: #33b5e1
5: #a363d5
6: #52cbb0
7: #a6afb8
8: #667581
9: #ef5253
10: #7cc844
11: #e4b51c
12: #33b5e1
13: #a363d5
14: #52cbb0
15: #f5f7fa
foreground: #a6afb8
background: #18262f
cursor: #a6afb8

solarflare-light
0: #f5f7fa
1: #ef5253
2: #7cc844
3: #e4b51c
4: #33b5e1
5: #a363d5
6: #52cbb0
7: #586875
8: #85939e
9: #ef5253
10: #7cc844
11: #e4b51c
12: #33b5e1
13: #a363d5
14: #52cbb0
15: #18262f
foreground: #586875
background: #f5f7fa
cursor: #586875

solarized-darcula
0: #25292a
1: #f24840
2: #629655
3: #b68800
4: #2075c7
5: #797fd4
6: #15968d
7: #d2d8d9
8: #25292a
9: #f24840
10: #629655
11: #b68800
12: #2075c7
13: #797fd4
14: #15968d
15: #d2d8d9
foreground: #d2d8d9
background: #3d3f41
cursor: #d2d8d9

solarized-dark
0: #002b36
1: #dc322f
2: #859900
3: #b58900
4: #268bd2
5: #6c71c4
6: #2aa198
7: #93a1a1
8: #657b83
9: #dc322f
10: #859900
11: #b58900
12: #268bd2
13: #6c71c4
14: #2aa198
15: #fdf6e3
foreground: #93a1a1
background: #002b36
cursor: #93a1a1

solarized-dark-higher-contrast
0: #002831
1: #d11c24
2: #6cbe6c
3: #a57706
4: #2176c7
5: #c61c6f
6: #259286
7: #eae3cb
8: #006488
9: #f5163b
10: #51ef84
11: #b27e28
12: #178ec8
13: #e24d8e
14: #00b39e
15: #fcf4dc
foreground: #9cc2c3
background: #001e27
cursor: #9cc2c3

solarized-light
0: #fdf6e3
1: #dc322f
2: #859900
3: #b58900
4: #268bd2
5: #6c71c4
6: #2aa198
7: #586e75
8: #839496
9: #dc322f
10: #859900
11: #b58900
12: #268bd2
13: #6c71c4
14: #2aa198
15: #002b36
foreground: #586e75
background: #fdf6e3
cursor: #586e75

source-code-x
0: #4e596b
1: #fb695d
2: #74b391
3: #fc8e3e
4: #9586f4
5: #fb5ea3
6: #79c8b6
7: #bfbfbf
8: #91a0b1
9: #fb695d
10: #aef37c
11: #fc8e3e
12: #53a4fb
13: #fb5ea3
14: #83d2c0
15: #91a0b1
foreground: #000000
background: #1f1f24
cursor: #7f7f7f

sourcerer
0: #111111
1: #aa4450
2: #719611
3: #ff9800
4: #6688aa
5: #8f6f8f
6: #528b8b
7: #d3d3d3
8: #181818
9: #ff6a6a
10: #b1d631
11: #87875f
12: #90b0d1
13: #8181a6
14: #87ceeb
15: #c1cdc1
foreground: #c2c2b0
background: #222222
cursor: #c2c2b0

sourcerer2
0: #111111
1: #aa4450
2: #719611
3: #ff9800
4: #6688aa
5: #8f6f8f
6: #528b8b
7: #d3d3d3
8: #181818
9: #ff6a6a
10: #b1d631
11: #87875f
12: #90b0d1
13: #8181a6
14: #87ceeb
15: #c1cdc1
foreground: #c2c2b0
background: #222222
cursor: #c2c2b0

spaceduck
0: #000000
1: #e33400
2: #5ccc96
3: #b3a1e6
4: #00a3cc
5: #f2ce00
6: #7a5ccc
7: #686f9a
8: #686f9a
9: #e33400
10: #5ccc96
11: #b3a1e6
12: #00a3cc
13: #f2ce00
14: #7a5ccc
15: #f0f1ce
foreground: #ecf0c1
background: #0f111b
cursor: #ecf0c1

spacedust
0: #6e5346
1: #e35b00
2: #5cab96
3: #e3cd7b
4: #0f548b
5: #e35b00
6: #06afc7
7: #f0f1ce
8: #684c31
9: #ff8a3a
10: #aecab8
11: #ffc878
12: #67a0ce
13: #ff8a3a
14: #83a7b4
15: #fefff1
foreground: #ecf0c1
background: #0a1e24
cursor: #ecf0c1

spacegray
0: #000000
1: #b04b57
2: #87b379
3: #e5c179
4: #7d8fa4
5: #a47996
6: #85a7a5
7: #b3b8c3
8: #000000
9: #b04b57
10: #87b379
11: #e5c179
12: #7d8fa4
13: #a47996
14: #85a7a5
15: #ffffff
foreground: #b3b8c3
background: #20242d
cursor: #b3b8c3

spacegray-eighties
0: #15171c
1: #ec5f67
2: #81a764
3: #fec254
4: #5486c0
5: #bf83c1
6: #57c2c1
7: #efece7
8: #555555
9: #ff6973
10: #93d493
11: #ffd256
12: #4d84d1
13: #ff55ff
14: #83e9e4
15: #ffffff
foreground: #bdbaae
background: #222222
cursor: #bdbaae

spacegray-eighties-dull
0: #15171c
1: #b24a56
2: #92b477
3: #c6735a
4: #7c8fa5
5: #a5789e
6: #80cdcb
7: #b3b8c3
8: #555555
9: #ec5f67
10: #89e986
11: #fec254
12: #5486c0
13: #bf83c1
14: #58c2c1
15: #ffffff
foreground: #c9c6bc
background: #222222
cursor: #c9c6bc

spacemacs
0: #1f2022
1: #f2241f
2: #67b11d
3: #b1951d
4: #4f97d7
5: #a31db1
6: #2d9574
7: #a3a3a3
8: #585858
9: #f2241f
10: #67b11d
11: #b1951d
12: #4f97d7
13: #a31db1
14: #2d9574
15: #f8f8f8
foreground: #a3a3a3
background: #1f2022
cursor: #a3a3a3

spiderman
0: #1b1d1e
1: #e60712
2: #e22828
3: #e24655
4: #2b3fff
5: #2435db
6: #3255ff
7: #fffef6
8: #505354
9: #ff0325
10: #ff3238
11: #fe3935
12: #1d4fff
13: #737bff
14: #6083ff
15: #fefff9
foreground: #e2e2e2
background: #1b1d1e
cursor: #2b3fff

spring
0: #000000
1: #ff4d83
2: #1f8c3b
3: #1fc95b
4: #1dd3ee
5: #8959a8
6: #3e999f
7: #ffffff
8: #000000
9: #ff0021
10: #1fc231
11: #d5b807
12: #15a9fd
13: #8959a8
14: #3e999f
15: #ffffff
foreground: #ecf0c1
background: #0a1e24
cursor: #ecf0c1

square
0: #050505
1: #e9897c
2: #b6377d
3: #ecebbe
4: #a9cdeb
5: #75507b
6: #c9caec
7: #f2f2f2
8: #141414
9: #f99286
10: #c3f786
11: #fcfbcc
12: #b6defb
13: #ad7fa8
14: #d7d9fc
15: #e2e2e2
foreground: #1a1a1a
background: #0a1e24
cursor: #1a1a1a

srcery
0: #1c1b19
1: #ef2f27
2: #519f50
3: #fbb829
4: #2c78bf
5: #e02c6d
6: #0aaeb3
7: #baa67f
8: #918175
9: #f75341
10: #98bc37
11: #fed06e
12: #68a8e4
13: #ff5c8f
14: #2be4d0
15: #fce8c3
foreground: #fce8c3
background: #1c1b19
cursor: #fbb829

substrata
0: #2e313d
1: #cf8164
2: #76a065
3: #ab924c
4: #8296b0
5: #a18daf
6: #659ea2
7: #b5b4c9
8: #5b5f71
9: #fe9f7c
10: #92c47e
11: #d2b45f
12: #a0b9d8
13: #c6aed7
14: #7dc2c7
15: #f0ecfe
foreground: #b5b4c9
background: #191c25
cursor: #b5b4c9

summercamp
0: #1c1810
1: #e35142
2: #5ceb5a
3: #f2ff27
4: #489bf0
5: #ff8080
6: #5aebbc
7: #736e55
8: #504b38
9: #e35142
10: #5ceb5a
11: #f2ff27
12: #489bf0
13: #ff8080
14: #5aebbc
15: #f8f5de
foreground: #736e55
background: #1c1810
cursor: #736e55

summerfruit-dark
0: #151515
1: #ff0086
2: #00c918
3: #aba800
4: #3777e6
5: #ad00a1
6: #1faaaa
7: #d0d0d0
8: #505050
9: #ff0086
10: #00c918
11: #aba800
12: #3777e6
13: #ad00a1
14: #1faaaa
15: #ffffff
foreground: #d0d0d0
background: #151515
cursor: #d0d0d0

summerfruit-light
0: #ffffff
1: #ff0086
2: #00c918
3: #aba800
4: #3777e6
5: #ad00a1
6: #1faaaa
7: #101010
8: #b0b0b0
9: #ff0086
10: #00c918
11: #aba800
12: #3777e6
13: #ad00a1
14: #1faaaa
15: #202020
foreground: #101010
background: #ffffff
cursor: #101010

sundried
0: #302b2a
1: #a7463d
2: #587744
3: #9d602a
4: #485b98
5: #864651
6: #9c814f
7: #c9c9c9
8: #4d4e48
9: #aa000c
10: #128c21
11: #fc6a21
12: #7999f7
13: #fd8aa1
14: #fad484
15: #ffffff
foreground: #c9c9c9
background: #1a1818
cursor: #c9c9c9

symphonic
0: #000000
1: #dc322f
2: #56db3a
3: #ff8400
4: #0084d4
5: #b729d9
6: #ccccff
7: #ffffff
8: #1b1d21
9: #dc322f
10: #56db3a
11: #ff8400
12: #0084d4
13: #b729d9
14: #ccccff
15: #ffffff
foreground: #ffffff
background: #000000
cursor: #ffffff

synth-midnight-dark
0: #050608
1: #b53b50
2: #06ea61
3: #c9d364
4: #03aeff
5: #ea5ce2
6: #42fff9
7: #c1c3c4
8: #474849
9: #b53b50
10: #06ea61
11: #c9d364
12: #03aeff
13: #ea5ce2
14: #42fff9
15: #dddfe0
foreground: #c1c3c4
background: #050608
cursor: #c1c3c4

synth-midnight-light
0: #dddfe0
1: #b53b50
2: #06ea61
3: #c9d364
4: #03aeff
5: #ea5ce2
6: #42fff9
7: #28292a
8: #a3a5a6
9: #b53b50
10: #06ea61
11: #c9d364
12: #03aeff
13: #ea5ce2
14: #42fff9
15: #050608
foreground: #28292a
background: #dddfe0
cursor: #28292a

tango
0: #2e3436
1: #cc0000
2: #4e9a06
3: #c4a000
4: #3465a4
5: #75507b
6: #06989a
7: #d3d7cf
8: #555753
9: #cc0000
10: #4e9a06
11: #c4a000
12: #3465a4
13: #75507b
14: #06989a
15: #eeeeec
foreground: #d3d7cf
background: #2e3436
cursor: #d3d7cf

tango-dark
0: #000000
1: #cc0000
2: #4e9a05
3: #c4a000
4: #3464a4
5: #74507a
6: #05989a
7: #d3d7cf
8: #545753
9: #ef2828
10: #8ae234
11: #fce94e
12: #719ecf
13: #ad7ea7
14: #34e2e2
15: #ededec
foreground: #ffffff
background: #000000
cursor: #ffffff

tango-light
0: #000000
1: #cc0000
2: #4e9a05
3: #c4a000
4: #3464a4
5: #74507a
6: #05989a
7: #d3d7cf
8: #545753
9: #ef2828
10: #8ae234
11: #fce94e
12: #719ecf
13: #ad7ea7
14: #34e2e2
15: #ededec
foreground: #000000
background: #ffffff
cursor: #000000

teerb
0: #1c1c1c
1: #d68686
2: #aed686
3: #d7af87
4: #86aed6
5: #d6aed6
6: #8adbb4
7: #d0d0d0
8: #1c1c1c
9: #d68686
10: #aed686
11: #e4c9af
12: #86aed6
13: #d6aed6
14: #b1e7dd
15: #efefef
foreground: #d0d0d0
background: #262626
cursor: #d0d0d0

tempus-autumn
0: #302420
1: #f16c50
2: #80a100
3: #ac9440
4: #7897c2
5: #dd758e
6: #52a485
7: #a5918a
8: #312e2a
9: #e07a3d
10: #43a770
11: #ba9000
12: #908ed4
13: #c57bc4
14: #2aa4ad
15: #a9a2a6
foreground: #a9a2a6
background: #302420
cursor: #a9a2a6

tempus-classic
0: #232323
1: #d2813d
2: #8c9e3d
3: #b1942b
4: #6e9cb0
5: #b58d88
6: #6da280
7: #949d9f
8: #312e30
9: #d0913d
10: #96a42d
11: #a8a030
12: #8e9cc0
13: #d58888
14: #7aa880
15: #aeadaf
foreground: #aeadaf
background: #232323
cursor: #aeadaf

tempus-dawn
0: #4a4b4e
1: #a32a3a
2: #206620
3: #745300
4: #4b529a
5: #8d377e
6: #086784
7: #e2e4e1
8: #686565
9: #ae4e2a
10: #1a7608
11: #8d5b0a
12: #5c5bb2
13: #8e47a8
14: #106e8c
15: #eff0f2
foreground: #4a4b4e
background: #eff0f2
cursor: #4a4b4e

tempus-day
0: #464340
1: #c81000
2: #107410
3: #806000
4: #385dc4
5: #b63052
6: #007070
7: #eae9dd
8: #68607d
9: #b94000
10: #4a7240
11: #706a00
12: #0d66c9
13: #8055aa
14: #337087
15: #f8f2e5
foreground: #464340
background: #f8f2e5
cursor: #464340

tempus-dusk
0: #1f252d
1: #cb8d56
2: #8ba089
3: #a79c46
4: #8c9abe
5: #b190af
6: #8e9aba
7: #a29899
8: #2c3150
9: #d39d74
10: #80b48f
11: #bda75a
12: #9ca5de
13: #c69ac6
14: #8caeb6
15: #a2a8ba
foreground: #a2a8ba
background: #1f252d
cursor: #a2a8ba

tempus-fugit
0: #4d595f
1: #c61a14
2: #357200
3: #825e00
4: #1666b0
5: #a83884
6: #007072
7: #f2ebe9
8: #7b6471
9: #bd401a
10: #447720
11: #985d00
12: #485ddf
13: #a438c0
14: #00786a
15: #fff5f3
foreground: #4d595f
background: #fff5f3
cursor: #4d595f

tempus-future
0: #090a18
1: #ff778a
2: #6ab539
3: #bfa01a
4: #4aaed3
5: #e58a82
6: #29b3bb
7: #a59ebd
8: #260e22
9: #f78e2f
10: #60ba80
11: #de9b1d
12: #8ba7ea
13: #e08bd6
14: #2cbab6
15: #b4abac
foreground: #b4abac
background: #090a18
cursor: #b4abac

tempus-night
0: #1a1a1a
1: #fb7e8e
2: #52ba40
3: #b0a800
4: #5aaaf2
5: #ee80c0
6: #1db5c3
7: #c4bdaf
8: #18143d
9: #f69d6a
10: #88c400
11: #d7ae00
12: #8cb4f0
13: #de99f0
14: #00ca9a
15: #e0e0e0
foreground: #e0e0e0
background: #1a1a1a
cursor: #e0e0e0

tempus-past
0: #53545b
1: #c00c50
2: #0a7040
3: #a6403a
4: #1763aa
5: #b02874
6: #096a83
7: #ece6de
8: #80565d
9: #bd3636
10: #407343
11: #9d524a
12: #5a5ebb
13: #b225ab
14: #07737a
15: #f3f2f4
foreground: #53545b
background: #f3f2f4
cursor: #53545b

tempus-rift
0: #162c22
1: #c19904
2: #34b534
3: #7fad00
4: #30aeb0
5: #c8954c
6: #5fad8f
7: #ab9aa9
8: #283431
9: #d2a634
10: #6ac134
11: #82bd00
12: #56bdad
13: #cca0ba
14: #10c480
15: #bbbcbc
foreground: #bbbcbc
background: #162c22
cursor: #bbbcbc

tempus-spring
0: #283a37
1: #ff855a
2: #5cbc4d
3: #a6af1a
4: #39b6ce
5: #e69092
6: #36bd84
7: #96aca7
8: #2a423d
9: #e19900
10: #6dbb0d
11: #c5a443
12: #70ade2
13: #d091db
14: #3cbaa6
15: #b5b8b7
foreground: #b5b8b7
background: #283a37
cursor: #b5b8b7

tempus-summer
0: #202c3d
1: #f76f6e
2: #4eac6d
3: #af9a0a
4: #609fda
5: #cc84ad
6: #3dab95
7: #919ab9
8: #352f49
9: #eb7b4d
10: #57ad47
11: #bd951a
12: #8196e8
13: #c97ed7
14: #2aa9b6
15: #a0abae
foreground: #a0abae
background: #202c3d
cursor: #a0abae

tempus-tempest
0: #282b2b
1: #c6c80a
2: #7ad67a
3: #bfc94a
4: #60d4cd
5: #c0c4aa
6: #8ad0b0
7: #b0c8ca
8: #303434
9: #d1d933
10: #99e299
11: #bbde4f
12: #74e4cd
13: #d2d4aa
14: #9bdfc4
15: #b6e0ca
foreground: #b6e0ca
background: #282b2b
cursor: #b6e0ca

tempus-totus
0: #4a484d
1: #a80000
2: #005f26
3: #714900
4: #1d3fcf
5: #882a7a
6: #185870
7: #f3f1f3
8: #5f4d4f
9: #9b2230
10: #4a5700
11: #8b3800
12: #2d48b0
13: #7310cb
14: #005589
15: #ffffff
foreground: #4a484d
background: #ffffff
cursor: #4a484d

tempus-warp
0: #001514
1: #fa3333
2: #139913
3: #9e8100
4: #557feb
5: #d54cbf
6: #009580
7: #928080
8: #241828
9: #f0681a
10: #3aa73a
11: #ba8a00
12: #8887f0
13: #d85cf2
14: #1da1af
15: #a29fa0
foreground: #a29fa0
background: #001514
cursor: #a29fa0

tempus-winter
0: #202427
1: #eb6a58
2: #49a61d
3: #959721
4: #798fd7
5: #cd7b7e
6: #4fa090
7: #909294
8: #292b35
9: #db7824
10: #00a854
11: #ad8e4b
12: #309dc1
13: #c874c2
14: #1ba2a0
15: #8da3b8
foreground: #8da3b8
background: #202427
cursor: #8da3b8

tender
0: #282828
1: #f43753
2: #c9d05c
3: #ffc24b
4: #b3deef
5: #d3b987
6: #73cef4
7: #eeeeee
8: #1d1d1d
9: #f43753
10: #c9d05c
11: #ffc24b
12: #b3deef
13: #d3b987
14: #73cef4
15: #ffffff
foreground: #eeeeee
background: #282828
cursor: #eeeeee

terminal-basic
0: #000000
1: #990000
2: #00a600
3: #999900
4: #0000b2
5: #b200b2
6: #00a6b2
7: #bfbfbf
8: #666666
9: #e50000
10: #00d900
11: #e5e500
12: #0000ff
13: #e500e5
14: #00e5e5
15: #e5e5e5
foreground: #000000
background: #ffffff
cursor: #000000

terminix-dark
0: #282a2e
1: #a54242
2: #a1b56c
3: #de935f
4: #225555
5: #85678f
6: #5e8d87
7: #777777
8: #373b41
9: #c63535
10: #608360
11: #fa805a
12: #449da1
13: #ba8baf
14: #86c1b9
15: #c5c8c6
foreground: #868a8c
background: #091116
cursor: #868a8c

thayer-bright
0: #1b1d1e
1: #f92672
2: #4df840
3: #f4fd22
4: #2757d6
5: #8c54fe
6: #38c8b5
7: #ccccc6
8: #505354
9: #ff5995
10: #b6e354
11: #feed6c
12: #3f78ff
13: #9e6ffe
14: #23cfd5
15: #f8f8f2
foreground: #f8f8f8
background: #1b1d1e
cursor: #f8f8f8

the-hulk
0: #1b1d1e
1: #259d1a
2: #13ce2f
3: #62e456
4: #2424f4
5: #641e73
6: #378ca9
7: #d8d8d0
8: #505354
9: #8dff2a
10: #48ff76
11: #3afe15
12: #4f6a95
13: #72579d
14: #3f85a5
15: #e5e5e0
foreground: #b4b4b4
background: #1b1d1e
cursor: #15b61a

tin
0: #000000
1: #8d534e
2: #4e8d53
3: #888d4e
4: #534e8d
5: #8d4e88
6: #4e888d
7: #ffffff
8: #000000
9: #b57d78
10: #78b57d
11: #b0b578
12: #7d78b5
13: #b578b0
14: #78b0b5
15: #ffffff
foreground: #ffffff
background: #2e2e35
cursor: #ffffff

tokyo-day
0: #e9e9ed
1: #f52a65
2: #587539
3: #8c6c3e
4: #2e7de9
5: #9854f1
6: #007197
7: #6172b0
8: #a1a6c5
9: #f52a65
10: #587539
11: #8c6c3e
12: #2e7de9
13: #9854f1
14: #007197
15: #3760bf
foreground: #3760bf
background: #e1e2e7
cursor: #3760bf

tokyo-night
0: #15161e
1: #f7768e
2: #9ece6a
3: #e0af68
4: #7aa2f7
5: #bb9af7
6: #7dcfff
7: #a9b1d6
8: #414868
9: #f7768e
10: #9ece6a
11: #e0af68
12: #7aa2f7
13: #bb9af7
14: #7dcfff
15: #c0caf5
foreground: #c0caf5
background: #1a1b26
cursor: #c0caf5

tokyo-storm
0: #1d202f
1: #f7768e
2: #9ece6a
3: #e0af68
4: #7aa2f7
5: #bb9af7
6: #7dcfff
7: #a9b1d6
8: #414868
9: #f7768e
10: #9ece6a
11: #e0af68
12: #7aa2f7
13: #bb9af7
14: #7dcfff
15: #c0caf5
foreground: #c0caf5
background: #24283b
cursor: #c0caf5

tomorrow
0: #ffffff
1: #c82829
2: #718c00
3: #eab700
4: #4271ae
5: #8959a8
6: #3e999f
7: #4d4d4c
8: #8e908c
9: #c82829
10: #718c00
11: #eab700
12: #4271ae
13: #8959a8
14: #3e999f
15: #1d1f21
foreground: #4d4d4c
background: #ffffff
cursor: #4d4d4c

tomorrow-night
0: #1d1f21
1: #cc6666
2: #b5bd68
3: #f0c674
4: #81a2be
5: #b294bb
6: #8abeb7
7: #c5c8c6
8: #969896
9: #cc6666
10: #b5bd68
11: #f0c674
12: #81a2be
13: #b294bb
14: #8abeb7
15: #ffffff
foreground: #c5c8c6
background: #1d1f21
cursor: #c5c8c6

tomorrow-night-blue
0: #000000
1: #ff9da3
2: #d1f1a9
3: #ffeead
4: #bbdaff
5: #ebbbff
6: #99ffff
7: #fffefe
8: #000000
9: #ff9ca3
10: #d0f0a8
11: #ffedac
12: #badaff
13: #ebbaff
14: #99ffff
15: #fffefe
foreground: #fffefe
background: #002451
cursor: #fffefe

tomorrow-night-bright
0: #000000
1: #d54e53
2: #b9ca49
3: #e7c547
4: #79a6da
5: #c397d8
6: #70c0b1
7: #fffefe
8: #000000
9: #d44d53
10: #b9c949
11: #e6c446
12: #79a6da
13: #c396d7
14: #70c0b1
15: #fffefe
foreground: #e9e9e9
background: #000000
cursor: #e9e9e9

tomorrow-night-eighties
0: #2d2d2d
1: #f2777a
2: #99cc99
3: #ffcc66
4: #6699cc
5: #cc99cc
6: #66cccc
7: #cccccc
8: #999999
9: #f2777a
10: #99cc99
11: #ffcc66
12: #6699cc
13: #cc99cc
14: #66cccc
15: #ffffff
foreground: #cccccc
background: #2d2d2d
cursor: #cccccc

toy-chest
0: #2c3f58
1: #be2d26
2: #1a9172
3: #db8e27
4: #325d96
5: #8a5edc
6: #35a08f
7: #23d183
8: #336889
9: #dd5944
10: #31d07b
11: #e7d84b
12: #34a6da
13: #ae6bdc
14: #42c3ae
15: #d5d5d5
foreground: #31d07b
background: #24364b
cursor: #31d07b

treehouse
0: #321300
1: #b2270e
2: #44a900
3: #aa820c
4: #58859a
5: #97363d
6: #b25a1e
7: #786b53
8: #433626
9: #ed5d20
10: #55f238
11: #f2b732
12: #85cfed
13: #e14c5a
14: #f07d14
15: #ffc800
foreground: #786b53
background: #191919
cursor: #786b53

tube
0: #231f20
1: #ee2e24
2: #00853e
3: #ffd204
4: #009ddc
5: #98005d
6: #85cebc
7: #d9d8d8
8: #737171
9: #ee2e24
10: #00853e
11: #ffd204
12: #009ddc
13: #98005d
14: #85cebc
15: #ffffff
foreground: #d9d8d8
background: #231f20
cursor: #d9d8d8

twilight
0: #1e1e1e
1: #cf6a4c
2: #8f9d6a
3: #f9ee98
4: #7587a6
5: #9b859d
6: #afc4db
7: #a7a7a7
8: #5f5a60
9: #cf6a4c
10: #8f9d6a
11: #f9ee98
12: #7587a6
13: #9b859d
14: #afc4db
15: #ffffff
foreground: #a7a7a7
background: #1e1e1e
cursor: #a7a7a7

two-firewatch
0: #282c34
1: #e06c75
2: #98c379
3: #e5c07b
4: #61afef
5: #c678dd
6: #56b6c2
7: #dcdfe4
8: #282c34
9: #e06c75
10: #98c379
11: #e5c07b
12: #61afef
13: #c678dd
14: #56b6c2
15: #dcdfe4
foreground: #abb2bf
background: #282c34
cursor: #abb2bf

unikitty-dark
0: #2e2a31
1: #d8137f
2: #17ad98
3: #dc8a0e
4: #796af5
5: #bb60ea
6: #149bda
7: #bcbabe
8: #838085
9: #d8137f
10: #17ad98
11: #dc8a0e
12: #796af5
13: #bb60ea
14: #149bda
15: #f5f4f7
foreground: #bcbabe
background: #2e2a31
cursor: #bcbabe

unikitty-light
0: #ffffff
1: #d8137f
2: #17ad98
3: #dc8a0e
4: #775dff
5: #aa17e6
6: #149bda
7: #6c696e
8: #a7a5a8
9: #d8137f
10: #17ad98
11: #dc8a0e
12: #775dff
13: #aa17e6
14: #149bda
15: #322d34
foreground: #6c696e
background: #ffffff
cursor: #6c696e

ura
0: #000000
1: #c21b6f
2: #6fc21b
3: #c26f1b
4: #1b6fc2
5: #6f1bc2
6: #1bc26f
7: #808080
8: #808080
9: #ee84b9
10: #b9ee84
11: #eeb984
12: #84b9ee
13: #b984ee
14: #84eeb9
15: #e5e5e5
foreground: #23476a
background: #feffee
cursor: #23476a

urple
0: #000000
1: #b0425b
2: #37a415
3: #ad5c42
4: #564d9b
5: #6c3ca1
6: #808080
7: #87799c
8: #5d3225
9: #ff6388
10: #29e620
11: #f08161
12: #867aed
13: #a05eee
14: #eaeaea
15: #bfa3ff
foreground: #877a9b
background: #1b1b23
cursor: #877a9b

vag
0: #303030
1: #a87139
2: #39a871
3: #71a839
4: #7139a8
5: #a83971
6: #3971a8
7: #8a8a8a
8: #494949
9: #b0763b
10: #3bb076
11: #76b03b
12: #763bb0
13: #b03b76
14: #3b76b0
15: #cfcfcf
foreground: #d9e6f2
background: #191f1d
cursor: #d9e6f2

vaughn
0: #25234f
1: #705050
2: #60b48a
3: #dfaf8f
4: #5555ff
5: #f08cc3
6: #8cd0d3
7: #709080
8: #709080
9: #dca3a3
10: #60b48a
11: #f0dfaf
12: #5555ff
13: #ec93d3
14: #93e0e3
15: #ffffff
foreground: #dcdccc
background: #25234f
cursor: #dcdccc

vibrant-ink
0: #878787
1: #ff6600
2: #ccff04
3: #ffcc00
4: #44b4cc
5: #9933cc
6: #44b4cc
7: #f5f5f5
8: #555555
9: #ff0000
10: #00ff00
11: #ffff00
12: #0000ff
13: #ff00ff
14: #00ffff
15: #e5e5e5
foreground: #ffffff
background: #000000
cursor: #ffffff

vs-code-dark-plus
0: #6a787a
1: #e9653b
2: #39e9a8
3: #e5b684
4: #44aae6
5: #e17599
6: #3dd5e7
7: #c3dde1
8: #598489
9: #e65029
10: #00ff9a
11: #e89440
12: #009afb
13: #ff578f
14: #5fffff
15: #d9fbff
foreground: #cccccc
background: #1e1e1e
cursor: #cccccc

vulcan
0: #041523
1: #818591
2: #977d7c
3: #adb4b9
4: #977d7c
5: #9198a3
6: #977d7c
7: #5b778c
8: #7a5759
9: #818591
10: #977d7c
11: #adb4b9
12: #977d7c
13: #9198a3
14: #977d7c
15: #214d68
foreground: #5b778c
background: #041523
cursor: #5b778c

warm-neon
0: #000000
1: #e24346
2: #39b13a
3: #dae145
4: #4261c5
5: #f920fb
6: #2abbd4
7: #d0b8a3
8: #fefcfc
9: #e97071
10: #9cc090
11: #ddda7a
12: #7b91d6
13: #f674ba
14: #5ed1e5
15: #d8c8bb
foreground: #afdab6
background: #404040
cursor: #afdab6

wez
0: #000000
1: #cc5555
2: #55cc55
3: #cdcd55
4: #5555cc
5: #cc55cc
6: #7acaca
7: #cccccc
8: #555555
9: #ff5555
10: #55ff55
11: #ffff55
12: #5555ff
13: #ff55ff
14: #55ffff
15: #ffffff
foreground: #b3b3b3
background: #000000
cursor: #b3b3b3

wild-cherry
0: #000507
1: #d94085
2: #2ab250
3: #ffd16f
4: #883cdc
5: #ececec
6: #c1b8b7
7: #fff8de
8: #009cc9
9: #da6bac
10: #f4dca5
11: #eac066
12: #308cba
13: #ae636b
14: #ff919d
15: #e4838d
foreground: #dafaff
background: #1f1726
cursor: #dafaff

windows-10
0: #0c0c0c
1: #e74856
2: #16c60c
3: #f9f1a5
4: #3b78ff
5: #b4009e
6: #61d6d6
7: #cccccc
8: #767676
9: #e74856
10: #16c60c
11: #f9f1a5
12: #3b78ff
13: #b4009e
14: #61d6d6
15: #f2f2f2
foreground: #cccccc
background: #0c0c0c
cursor: #cccccc

windows-10-light
0: #f2f2f2
1: #c50f1f
2: #13a10e
3: #c19c00
4: #0037da
5: #881798
6: #3a96dd
7: #767676
8: #cccccc
9: #c50f1f
10: #13a10e
11: #c19c00
12: #0037da
13: #881798
14: #3a96dd
15: #0c0c0c
foreground: #767676
background: #f2f2f2
cursor: #767676

windows-95
0: #000000
1: #fc5454
2: #54fc54
3: #fcfc54
4: #5454fc
5: #fc54fc
6: #54fcfc
7: #a8a8a8
8: #545454
9: #fc5454
10: #54fc54
11: #fcfc54
12: #5454fc
13: #fc54fc
14: #54fcfc
15: #fcfcfc
foreground: #a8a8a8
background: #000000
cursor: #a8a8a8

windows-95-light
0: #fcfcfc
1: #a80000
2: #00a800
3: #a85400
4: #0000a8
5: #a800a8
6: #00a8a8
7: #545454
8: #a8a8a8
9: #a80000
10: #00a800
11: #a85400
12: #0000a8
13: #a800a8
14: #00a8a8
15: #000000
foreground: #545454
background: #fcfcfc
cursor: #545454

windows-highcontrast
0: #000000
1: #fc5454
2: #54fc54
3: #fcfc54
4: #5454fc
5: #fc54fc
6: #54fcfc
7: #c0c0c0
8: #545454
9: #fc5454
10: #54fc54
11: #fcfc54
12: #5454fc
13: #fc54fc
14: #54fcfc
15: #fcfcfc
foreground: #c0c0c0
background: #000000
cursor: #c0c0c0

windows-highcontrast-light
0: #fcfcfc
1: #800000
2: #008000
3: #808000
4: #000080
5: #800080
6: #008080
7: #545454
8: #c0c0c0
9: #800000
10: #008000
11: #808000
12: #000080
13: #800080
14: #008080
15: #000000
foreground: #545454
background: #fcfcfc
cursor: #545454

windows-nt
0: #000000
1: #ff0000
2: #00ff00
3: #ffff00
4: #0000ff
5: #ff00ff
6: #00ffff
7: #c0c0c0
8: #808080
9: #ff0000
10: #00ff00
11: #ffff00
12: #0000ff
13: #ff00ff
14: #00ffff
15: #ffffff
foreground: #c0c0c0
background: #000000
cursor: #c0c0c0

windows-nt-light
0: #ffffff
1: #800000
2: #008000
3: #808000
4: #000080
5: #800080
6: #008080
7: #808080
8: #c0c0c0
9: #800000
10: #008000
11: #808000
12: #000080
13: #800080
14: #008080
15: #000000
foreground: #808080
background: #ffffff
cursor: #808080

wombat
0: #000000
1: #ff615a
2: #b1e969
3: #ebd99c
4: #5da9f6
5: #e86aff
6: #82fff7
7: #dedacf
8: #313131
9: #f58c80
10: #ddf88f
11: #eee5b2
12: #a5c7ff
13: #ddaaff
14: #b7fff9
15: #ffffff
foreground: #dedacf
background: #171717
cursor: #dedacf

woodland
0: #231e18
1: #d35c5c
2: #b7ba53
3: #e0ac16
4: #88a4d3
5: #bb90e2
6: #6eb958
7: #cabcb1
8: #9d8b70
9: #d35c5c
10: #b7ba53
11: #e0ac16
12: #88a4d3
13: #bb90e2
14: #6eb958
15: #e4d4c8
foreground: #cabcb1
background: #231e18
cursor: #cabcb1

wryan
0: #333333
1: #8c4665
2: #287373
3: #7c7c99
4: #395573
5: #5e468c
6: #31658c
7: #899ca1
8: #3d3d3d
9: #bf4d80
10: #53a6a6
11: #9e9ecb
12: #477ab3
13: #7e62b3
14: #6096bf
15: #c0c0c0
foreground: #999993
background: #101010
cursor: #999993

xcode-dusk
0: #282b35
1: #b21889
2: #df0002
3: #438288
4: #790ead
5: #b21889
6: #00a0be
7: #939599
8: #686a71
9: #b21889
10: #df0002
11: #438288
12: #790ead
13: #b21889
14: #00a0be
15: #bebfc2
foreground: #939599
background: #282b35
cursor: #939599

yachiyo
0: #ff509c
1: #86b79b
2: #b9a9d7
3: #d4b34e
4: #ada883
5: #9298e7
6: #ff9c9c
7: #a0be99
8: #ff509c
9: #86b79b
10: #b9a9d7
11: #d4b34e
12: #ada883
13: #9298e7
14: #ff9c9c
15: #a0be99
foreground: #ffb692
background: #44515d
cursor: #ffb692

zenburn
0: #383838
1: #dca3a3
2: #5f7f5f
3: #e0cf9f
4: #7cb8bb
5: #dc8cc3
6: #93e0e3
7: #dcdccc
8: #6f6f6f
9: #dca3a3
10: #5f7f5f
11: #e0cf9f
12: #7cb8bb
13: #dc8cc3
14: #93e0e3
15: #ffffff
foreground: #dcdccc
background: #383838
cursor: #dcdccc

