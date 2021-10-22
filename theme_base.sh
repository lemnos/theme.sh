#!/bin/sh

# Written by Aetnaeus.
# Source: https://github.com/lemnos/theme.sh.
# Licensed under the WTFPL provided this notice is preserved.

# Find a broken theme? Want to add a missing one? PRs are welcome.

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

apply() {
	awk -F": " -v target="$1" '
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

		/^# Themes/ { start++;next; }
		!start { next }

		$0 == target {found++}

		found && /^foreground:/ {fg=$2}
		found && /^background:/ {bg=$2}
		found && /^[0-9]+:/ {colors[int($1)]=$2}
		found && /^cursor:/ {cursor=$2}

		found && /^ *$/ { exit }

		END {
			if(found) {
				for(c in colors)
					printf colesc, c, substr(colors[c], 2) > "/dev/tty"

				printf fgesc, substr(fg, 2) > "/dev/tty"
				printf bgesc, substr(bg, 2) > "/dev/tty"
				printf curesc, substr(cursor, 2) > "/dev/tty"

				histfile=ENVIRON["HOME"]"/.theme_history"
				inhibit_hist=ENVIRON["INHIBIT_THEME_HIST"]

				if(!inhibit_hist) {
					while((getline < histfile) > 0)
						if($0 != target)
							out = out $0 "\n"
					close(histfile)

					out = out target
					print out > histfile
				}
			}
		}
	' < "$0"
}

isColorTerm() {
	if [ -z "$TMUX" ]; then
		[ ! -z "$COLORTERM" ]
	else
		tmux display-message -p '#{client_termfeatures}'|grep -q 256
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
			histfile=ENVIRON["HOME"]"/.theme_history"
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
	echo "Usage: $(basename "$0") [--light] [--dark] [-l|--list] [-i|--interactive] [-i2|--interactive2] [-r|--random] [-a|--add <kitty config>] <theme>"
	exit
fi

case "$1" in
	--dark|--light)
		filterFlag=$1
		shift
		;;
esac

case "$1" in
-i2|--interactive2)
	command -v fzf > /dev/null 2>&1 || { echo "ERROR: -i requires fzf" >&2; exit 1; }
	"$0" $filterFlag -l|fzf\
		--tac\
		--bind "enter:execute-silent($0 {})"\
		--bind "down:down+execute-silent(INHIBIT_THEME_HIST=1 $0 {})"\
		--bind "up:up+execute-silent(INHIBIT_THEME_HIST=1 $0 {})"\
		--bind "change:execute-silent(INHIBIT_THEME_HIST=1 $0 {})"\
		--bind "ctrl-c:execute($0 {};echo {})+abort"\
		--bind "esc:execute($0 {};echo {})+abort"\
		--no-sort\
		--preview "$0 --preview2"
	;;
-r|--random)
	theme=$($0 $filterFlag -l|sort -R|head -n1)
	$0 "$theme"
	echo "Theme: $theme"
	;;
-i|--interactive)
	command -v fzf > /dev/null 2>&1 || { echo "ERROR: -i requires fzf" >&2; exit 1; }
	if ! isColorTerm; then
		echo "This does not appear to be a truecolor terminal, try -i2 instead or set COLORTERM if your terminal has truecolor support."
		exit 1
	else
		"$0" $filterFlag -l|fzf\
			--tac\
			--bind "ctrl-c:execute(echo {})+abort"\
			--bind "esc:execute(echo {})+abort"\
			--bind "enter:execute-silent($0 {})"\
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
*)
	apply "$1"
	;;
esac

exit $?

# Themes start here (avoid editing by hand)
