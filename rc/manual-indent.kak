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

    hook -group manual-indent-spaces window InsertChar '\t' manual-indent-tab-inserted
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
}
