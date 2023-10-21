# What

One theme script to rule them all.

# Features

 - 400+ precompiled themes
 - [Terminal agnostic](#supported-terminals) (works on any terminal with OSC 4/11 support (e.g st, kitty, iterm))
 - Keeps history
 - [Script](#scripting-examples) friendly
 - Portable (a single <130k file with all 400 themes included)
 - Dark/Light filters so you can decide when you want to burn your retinas.
 - [Interactive](#demo) (requires [fzf](https://github.com/junegunn/fzf))
 - [Self modifying](#adding-themes) (can ingest kitty themes).
 - Small, self contained and POSIX compliant 

# Demo

![](demo.gif)

# Why?

 - So you can easily switch themes inside of an open terminal.
 - So you can keep your shell's init file as the single source of truth.
 - So you can configure different themes for all your boxen (see [scripting](#scripting-examples)).
 - So you can configure st without recompiling it :P.
 - ~~So you can liberate your mind from the drudgery of the cubicle.~~.

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

# Examples

See `theme.sh -h` for a full list of options.


```
> theme.sh --dark --list

  zenburn
  gruvbox
  solarized-dark
  ...

> theme.sh zenburn
```

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
	bind -x '"\C-o":"theme.sh $(theme.sh -l|tail -n2|head -n1)"'

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

## `~/.config/fish/config.fish`

```
if status is-interactive
    if type -q theme.sh
        if test -e ~/.theme_history
        theme.sh (theme.sh -l|tail -n1)
        end

        # Optional
        # Bind C-o to the last theme.
        function last_theme
            theme.sh (theme.sh -l|tail -n2|head -n1)
        end

        bind \co last_theme

        alias th='theme.sh -i'

        # Interactively load a light theme
        alias thl='theme.sh --light -i'

        # Interactively load a dark theme
        alias thd='theme.sh --dark -i'
    end
end
```



## Recommended `~/.vimrc`

```
colorscheme default
set notermguicolors
highlight Search ctermfg=0
```

The above makes vim play nicely with the stock terminal theme.

# Scripting Examples

## Example sudo/su wrapper.

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

You could also do something on the server side using `-p` for restoration, but
it requires a terminal which supports OSC query sequences and is less widely
supported.

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
 - st
 - Terminal.app (osx)
 - iTerm2
 - alacritty
 - urxvt (non interactively unless the truecolor patch is applied)
 - any libvte based terminal


# Caveats

 - Requires a terminal that properly implements OSC 4/11.
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

