provide-module manual-indent %{
  define-command manual-indent-enable -docstring 'Enable manual-indent' %{
    hook -group manual-indent window InsertChar '\n' manual-indent-new-line-inserted
    hook -group manual-indent window InsertChar '\t' manual-indent-tab-inserted
    hook -group manual-indent window InsertDelete ' ' manual-indent-space-deleted
  }
  define-command manual-indent-disable -docstring 'Disable manual-indent' %{
    remove-hooks window manual-indent
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
