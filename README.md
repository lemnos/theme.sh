# What

One theme script to rule them all.

# Features

 - 150+ preloaded themes.
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

# Usage

Put theme.sh somewhere in your `$PATH`

Then:


```
> theme.sh -l
  
  zenburn
  gruvbox
  solarized-dark
  ...

> theme.sh zenburn
```

or simply

```
> theme.sh -i #Interactive theme selection (requires fzf)
```

Once you find something you like simply put

```
theme.sh <theme>
```

in your `~/.bashrc`

If `$CURRENT_THEME_FILE` is set then the current theme will be written to the
path it contains when `theme.sh` temrinates. Thus to make theme changes
persistent you can simply add

```
export CURRENT_THEME_FILE=~/.current_theme
[ -e "$CURRENT_THEME_FILE" ] && theme.sh "$(cat "$CURRENT_THEME_FILE")"
```

to your `~/.bashrc`.

# Supported Terminals

Below is a list of terminals on which theme.sh is known to work:
	
 - kitty
 - gnome-terminal
 - terminator
 - st
 - Terminal.app (osx)
 - iTerm2
 - alacritty
 - urxvt (non interactively unless the truecolor patch is installed)
 - any libvte based terminal


# Caveats

 - Requires a shell that properly implements OSC 4/11.
 - Interactive mode also requires TRUECOLOR support (though the theme can still be set without it.)
 - May cause an imperceptible flash when you start your terminal.
 - Will not help you achieve enlightenment or improve your marriage.
 - May cause epilepsy.

# Known issues

 - Will not work in screen (tmux uses the same TERM variable)
