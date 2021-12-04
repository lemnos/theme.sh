# What

One theme script to rule them all.

# Features

 - 270+ preloaded themes.
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
  - https://github.com/chriskempson/base16-iterm2

 A debt of gratitude is owed to these projects as well as well as those who
 contributed directly to the repo, and of course the theme authors themselves.
 A non exhaustive list of theme authors can be found in [CREDITS](CREDITS.md) if you are
 the author of a theme and wish to be listed feel free to submit a PR or
 contact me directly :).

