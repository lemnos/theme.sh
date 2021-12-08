# What

One theme script to rule them all.

# Features

 - 400+ preloaded themes.
 - Terminal agnostic (works on any terminal with OSC 4/11 support (e.g st, kitty, iterm))
 - Small, self contained and POSIX compliant.
 - History
 - Script friendly
 - Interactive theme selection (requires [fzf](https://github.com/junegunn/fzf))

# Demo

![](demo.gif)

# Why?

 - Lets you easily switch themes inside of an open terminal.
 - Lets you configure st's colour theme without recompiling it :P
 - Lets you keep your shell's init file as the single source of truth.
 - Lets you script theme changes

# Installation

Simply put `theme.sh` somewhere in your path.

E.G

```
sudo curl -Lo /usr/bin/theme.sh 'https://git.io/JM70M' && sudo chmod +x /usr/bin/theme.sh
```

or (OSX)

```
sudo curl -Lo /usr/local/bin/theme.sh 'https://git.io/JM70M' && sudo chmod +x /usr/local/bin/theme.sh
```

# Usage


```
usage: theme.sh [--light] | [--dark] <option> | <theme>

  If <theme> is provided it will immediately be set. Otherwise --dark or
  --light optionally act as filters on the supplied option. Theme history
  is stored in ~/.theme_history by default and will be used for ordering
  the otherwise alphabetical theme list in the relevant options (-l/-i/-i2).

  E.G:
    'theme.sh --dark -i'

  will start an interactive selection of dark themes with the user's
  most recently selected themes at the bottom of the list.

OPTIONS
  -l,--list               Print all available themes to STDOUT.
  -i,--interactive        Start the interactive selection mode (requires fzf).
  -i2,--interactive2      Interactive mode #2.  This shows the theme immediately instead of showing it
                          in the preview window. Useful if your terminal does have TRUECOLOR support.
  -r,--random             Sets a random theme and prints it to STDOUT.
  -a,--add <kitty config> Annexes the given kitty config file.
  -v,--version            Print the version and exit.

SCRIPTING
  If used from within a script, you will probably want to set
  INHIBIT_THEME_HIST=1 to avoid mangling the user's theme history.
```

## Examples

```
> theme.sh -l

  zenburn
  gruvbox
  solarized-dark
  ...

> theme.sh zenburn
```

or

```
> theme.sh -i #Interactive theme selection (requires fzf)
```

Once you find something you like simply put

```
theme.sh <theme>
```

in your `~/.bashrc`.

# Configuration

## Recommended `~/.bashrc`

To load the most recently selected theme automatically you can put

```
if command -v theme.sh > /dev/null; then
	[ -e ~/.theme_history ] && theme.sh "$(theme.sh -l|tail -n1)"

	# Optional

	#Binds C-o to the previously active theme.
	bind -x '"\x0f":"theme.sh $(theme.sh -l|tail -n2|head -n1)"'

	alias th='theme.sh -i'

	# Interactively load a light theme
	alias thl='theme.sh --light -i'

	# Interactively load a dark theme
	alias thd='theme.sh --dark -i'
fi
```

in your `~/.bashrc`.

## `~/.zshrc`
```
if command -v theme.sh > /dev/null; then
	[ -e ~/.theme_history ] && theme.sh "$(theme.sh -l|tail -n1)"

	# Optional

	# Bind C-o to the last theme.
	last_theme() {
		theme.sh "$(theme.sh -l|tail -n2|head -n1)"
	}

	zle -N last_theme
	bindkey '^O' last_theme

	alias th='theme.sh -i'

	# Interactively load a light theme
	alias thl='theme.sh --light -i'

	# Interactively load a dark theme
	alias thd='theme.sh --dark -i'
fi
```


## Recommended `~/.vimrc`

```
colorscheme default
set notermguicolors
highlight Search ctermfg=0
```

The above makes vim play nicely with the stock terminal theme.

# Scripting Examples

## Example root themeing logic

The following shellrc snippet will set the theme to 'red-alert' when
su is used or sudo is run with a long running (> .2s) command. It assumes 
theme.sh has been used to set the current theme (as in the recommended
`~/.bashrc`).

```
su() {
	(
		INHIBIT_THEME_HIST=1 theme.sh red-alert
		trap 'theme.sh "$(theme.sh -l|tail -n1)"' INT
		env su "$@"
		theme.sh "$(theme.sh -l|tail -n1)"
	)
}

sudo() {
	(
		pid=$(exec sh -c 'echo "$PPID"')

		# If the command takes less than .2s, don't change the theme.
		# We could also just match on 'su' and ignore everything else,
		# but this also accomodates other long running commands
		# like 'sudo sleep 5s'. Modify to taste.

		(
				sleep .2s
				ps -p "$pid" > /dev/null && INHIBIT_THEME_HIST=1 theme.sh red-alert
		) &

		trap 'theme.sh "$(theme.sh -l|tail -n1)"' INT
		env sudo "$@"
		theme.sh "$(theme.sh -l|tail -n1)"
	)
}
```

## SSH Integration

Put the snippet in your shellrc:

and then

`~/.ssh_themes`:

```
host1: zenburn
host2: red-alert
...
```

```
ssh() {
	# A tiny ssh wrapper which extracts a theme from ~/.ssh_themes
	# and applies it for the duration of the current ssh command.
	# Each line in ~/.ssh_themes has the format:
	#     <hostname>: <theme>.

	# Restoration relies on the fact that you are using theme.sh to manage
	# the current theme.  (that is, you set the theme in your bashrc.)

	# This can probably be made more robust. It is just a small demo
	# of what is possible.


	touch ~/.ssh_themes

	host="$(echo "$@"|awk '{gsub(".*@","",$NF);print $NF}')"
	theme="$(awk -vhost="$host" -F': *' 'index($0, host":") == 1 {print $2}' < ~/.ssh_themes)"

	if [ -z "$theme" ]; then
		env ssh "$@"
		return
	fi

	INHIBIT_THEME_HIST=1 theme.sh "$theme"
	trap 'theme.sh "$(theme.sh -l|tail -n1)"' INT
	env ssh "$@"
	theme.sh "$(theme.sh -l|tail -n1)"
}
```

You could also do something on the server side using `-p` for restoration, but it is less widely
supported and you risk mangling client side config.

## Adding Themes

If theme.sh is writable by the user executing it, kitty style theme configs can
be annexed directly to the script with `--add`. This allows you to grow your
own self contained theme file which you can scp to all your boxen. Just don't
forget to upstream your changes :P. See [CONTRIBUTING](CONTRIBUTING.md) for instructions
on adding themes to this repo.

E.G

```
curl -O 'https://raw.githubusercontent.com/dexpota/kitty-themes/master/themes/Solarized_Darcula.conf'
theme.sh --add Solarized_Darcula.conf
theme.sh Solarized_Darcula
```

If a theme with the same name already exists it will be overwritten.

Note that adding themes requires write access to the script and may require `sudo` for system-wide installations.

If you find a theme that is already not included in the script you are encouraged to submit a PR (see [CONTRIBUTING](CONTRIBUTING.md)).

# Supported Terminals

Below is a list of terminals on which theme.sh is known to work:
	
 - [kitty](https://github.com/kovidgoyal/kitty) (not KiTTY)
 - gnome-terminal
 - terminator
 - st with the [appropriate patch](https://st.suckless.org/patches/osc_10_11_12_2)
 - Terminal.app (osx)
 - iTerm2
 - alacritty
 - urxvt (non interactively unless the truecolor patch is applied)
 - any libvte based terminal


# Caveats

 - Requires a shell that properly implements OSC 4/11.
 - Interactive mode also requires TRUECOLOR support (though the theme can still be set without it.)
 - May cause an imperceptible flash when you start your terminal.
 - Will not help you achieve enlightenment or improve your marriage.
 - May cause epilepsy.

# Known issues

 - Will not work in screen (tmux uses the same TERM variable)

# Acknowledgements

Themes were contributed by numerous github contributors as well as scraped
 from various projects. Some of the larger respositories include:

  - https://github.com/dexpota/kitty-themes
  - https://github.com/mbadolato/iTerm2-Color-Schemes
  - https://github.com/aarowill/base16-gnome-terminal
  - https://github.com/chriskempson/base16-iterm2

 A debt of gratitude is owed to these projects as well as well as those who
 contributed directly to the repo, and of course the theme authors themselves.
 A non exhaustive list of theme authors can be found in [CREDITS](CREDITS.md). If you are
 the author of a theme and wish to be listed feel free to submit a PR or
 contact me directly :).

