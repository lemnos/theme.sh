# Contributions

Contributions are welcome but should conform to the rules listed below.

## Adding Themes

Adding a new theme is a simple matter of putting a kitty style config in
`themes/` and running `make`. Please avoid adding themes by editing the script
by hand. 

For consistency all themes should be kebab-cased and follow similar conventions
to the ones already found in `themes/`. Finally, if available, please include the
original authors in [CREDITS.md](CREDITS.md).

E.G

```
curl -o themes/solarized-darcula 'https://raw.githubusercontent.com/dexpota/kitty-themes/master/themes/Solarized_Darcula.conf'
make
```

If the theme you wish to add does not exist for kitty create the
corresponding config file in themes/. The format is straightforward and self
documenting. Note that all parameters are mandatory and extraneous ones
will be ignored.
