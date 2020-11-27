provide-module manual-indent %{
  # Enable manual-indent
  define-command manual-indent-enable -docstring 'Enable manual-indent' %{
    # New line inserted
    hook -group manual-indent window InsertChar '\n' manual-indent-new-line-inserted

    # Tabs versus Spaces
    evaluate-commands %sh{
      if test "$kak_opt_indentwidth" -eq 0; then
        printf 'manual-indent-tabs'
      else
        printf 'manual-indent-spaces'
      fi
    }

    # Indent with tabs
    hook -group manual-indent window WinSetOption 'indentwidth=0' %{
      manual-indent-tabs
    }

    # Indent with spaces
    hook -group manual-indent window WinSetOption 'indentwidth=[^0]' %{
      manual-indent-spaces
    }
  }

  # Disable manual-indent
  define-command manual-indent-disable -docstring 'Disable manual-indent' %{
    remove-hooks window 'manual-indent|manual-indent-.+'
  }

  # Indent with spaces
  define-command manual-indent-spaces -docstring 'Indent with spaces' %{
    remove-hooks window manual-indent-spaces

    map window insert <tab> '<a-;>: insert-soft-tab<ret>'
    hook -group manual-indent-spaces window InsertDelete ' ' manual-indent-space-deleted
  }

  # Indent with tabs
  define-command manual-indent-tabs -docstring 'Indent with tabs' %{
    remove-hooks window manual-indent-spaces
  }

  # Remove filetype hooks
  #
  # By convention, filetype hooks are added to the window scope under the following names:
  #
  # – {filetype}
  # – {filetype}-{something}
  #
  define-command manual-indent-remove-filetype-hooks -docstring 'Remove filetype hooks' %{
    remove-hooks window "%opt{filetype}|%opt{filetype}-.+"
  }

  # Restore filetype hooks
  define-command manual-indent-restore-filetype-hooks -docstring 'Restore filetype hooks' %{
    evaluate-commands -save-regs 'f' %{
      set-register f %opt{filetype}

      set-option buffer filetype ''
      set-option buffer filetype %reg{f}
    }
  }

  # New line inserted
  define-command -hidden manual-indent-new-line-inserted %{
    # Copy previous line indent
    try %{
      execute-keys -draft 'K<a-&>'
    }

    # Remove empty line indent
    try %{
      execute-keys -draft 'k<a-x>s^\h+$<ret>d'
    }
  }

  # Tab inserted
  define-command -hidden manual-indent-tab-inserted %{
    try %{
      execute-keys -draft "h<a-h><a-k>\A\h+\z<ret><a-;>;%opt{indentwidth}@"
    }
  }

  # Space inserted
  define-command -hidden manual-indent-space-deleted %{
    try %{
      execute-keys -draft 'h<a-h><a-k>\A\h+\z<ret>i<space><esc><lt>'
    }
  }

  # Insert soft tab (only at start of line or if preceded only by whitespace)
  define-command -hidden insert-soft-tab %{
    # <a-h><a-K>\S{2}<ret>  # expand selections leftward, then reject selections containing consecutive non-whitespace characters
    # s(?S)^.*(?=.)|^$<ret> # remove last character (original cursor location) from each selection longer than one character
    # <a-k>^(|.|\h+)\z<ret> # keep single-character selections (cursor at start of line or newline) and whitespace-only selections
    # ;i<space><esc>h""sd   # insert one space, then delete-yank that space to 's' register
    # %opt{indentwidth}""sP # paste 's' register 'indentwidth times' after cursor
    try %{ execute-keys -draft "<a-h><a-K>\S{2}<ret>s(?S)^.*(?=.)|^$<ret><a-k>^(|.|\h+)\z<ret>;i<space><esc>h""sd%opt{indentwidth}""sP" }
  }

}
