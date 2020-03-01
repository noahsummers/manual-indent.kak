provide-module manual-indent %{
  define-command manual-indent-enable -docstring 'Enable manual-indent' %{
    hook -group manual-indent window InsertChar '\n' manual-indent-new-line-inserted
    # Tabs versus Spaces
    evaluate-commands %sh{
      if test "$kak_opt_indentwidth" -eq 0; then
        printf 'manual-indent-tabs'
      else
        printf 'manual-indent-spaces'
      fi
    }
    hook -group manual-indent window WinSetOption 'indentwidth=0' %{
      manual-indent-tabs
    }
    hook -group manual-indent window WinSetOption 'indentwidth=[^0]' %{
      manual-indent-spaces
    }
  }
  define-command manual-indent-disable -docstring 'Disable manual-indent' %{
    remove-hooks window 'manual-indent|manual-indent-.+'
  }
  define-command manual-indent-spaces -docstring 'Indent with spaces' %{
    remove-hooks window manual-indent-spaces
    hook -group manual-indent-spaces window InsertChar '\t' manual-indent-tab-inserted
    hook -group manual-indent-spaces window InsertDelete ' ' manual-indent-space-deleted
  }
  define-command manual-indent-tabs -docstring 'Indent with tabs' %{
    remove-hooks window manual-indent-spaces
  }
  # By convention, filetype hooks are added to the window scope under the following names:
  # – {filetype}
  # – {filetype}-{something}
  define-command manual-indent-remove-filetype-hooks -docstring 'Remove filetype hooks' %{
    remove-hooks window "%opt{filetype}|%opt{filetype}-.+"
  }
  define-command manual-indent-restore-filetype-hooks -docstring 'Restore filetype hooks' %{
    evaluate-commands -save-regs 'f' %{
      set-register f %opt{filetype}
      set-option buffer filetype ''
      set-option buffer filetype %reg{f}
    }
  }
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
  define-command -hidden manual-indent-tab-inserted %{
    try %{
      execute-keys -draft "h<a-h><a-k>\A\h+\z<ret><a-;>;%opt{indentwidth}@"
    }
  }
  define-command -hidden manual-indent-space-deleted %{
    try %{
      execute-keys -draft 'h<a-h><a-k>\A\h+\z<ret>i<space><esc><lt>'
    }
  }
}

require-module manual-indent
