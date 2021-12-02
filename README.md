# What

One theme script to rule them all.

# Features

 - 270+ preloaded themes.
 - Works on any terminal with OSC 4/11 support (e.g kitty, osx term)
 - Small, self contained and POSIX compliant.
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
sudo curl -o /usr/bin/theme.sh 'https://raw.githubusercontent.com/lemnos/theme.sh/master/theme.sh' && sudo chmod +x /usr/bin/theme.sh
```

or (OSX)

```
sudo curl -o /usr/local/bin/theme.sh 'https://raw.githubusercontent.com/lemnos/theme.sh/master/theme.sh' && sudo chmod +x /usr/local/bin/theme.sh
```

# Usage



```
Usage: theme.sh [--light] [--dark] [-l|--list] [-i|--interactive] [-i2|--interactive2] [-r|--random] [-a|--add <kitty config>] <theme>
```

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

	bind -x '"\x0f":"theme.sh $(theme.sh -l|tail -n2|head -n1)"' #Binds C-o to the previously active theme.
	alias th='theme.sh -i'

	# Interactively load a light theme
	alias thl='theme.sh --light -i'

	# Interactively load a dark theme
	alias thd='theme.sh --dark -i'
fi
```

in your `~/.bashrc`.

## Recommended `~/.vimrc`

```
colorscheme default
set notermguicolors
highlight Search ctermfg=0
```

The above makes vim play nicely with the stock terminal theme.

## Adding Themes

Kitty style theme configs can be ingested via `--add`. The filename is used as the theme name.

E.G

```
curl -O 'https://raw.githubusercontent.com/dexpota/kitty-themes/master/themes/Solarized_Darcula.conf'
theme.sh --add Solarized_Darcula.conf
theme.sh Solarized_Darcula
```

If a theme with the same name already exists it will be overwritten.

Note that adding themes requires write access to the script and may require `sudo` for system-wide installations.

If you find a theme that is already not included in the script you are encouraged to submit a PR (see CONTRIBUTING.md).

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
  - https://github.com/chriskempson/base16-iterm2

 A debt of gratitude is owed to these projects as well as well as those
 who contributed directly to the repo, and of course the theme authors
 themselves. A non exhaustive list of theme authors can be found in CREDITS.md
 if you are the author of a theme and wish to be listed feel free to
 submit a PR or contact me directly :).

