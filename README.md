# manual-indent.kak

Manual indenting for [Kakoune].

## Features

- <kbd>Return</kbd> ⇒ Copy previous line indent.
- <kbd>Tab</kbd> ⇒ Indent at line start.
- <kbd>Backspace</kbd> ⇒ Deindent at line start.

## Installation

Add [`manual-indent.kak`](rc/manual-indent.kak) to your autoload or source it manually.

``` kak
require-module manual-indent
```

## Usage

Enable manual indenting with `manual-indent-enable`.
You can disable it with `manual-indent-disable`.
You can also disable and restore filetype hooks with `manual-indent-remove-filetype-hooks` and `manual-indent-restore-filetype-hooks`.

## Configuration

``` kak
hook global WinCreate .* %{
  manual-indent-enable
}

hook global WinSetOption filetype=.* %{
  manual-indent-remove-filetype-hooks
}
```

[Kakoune]: https://kakoune.org
