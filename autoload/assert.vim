function! assert#buffer_changed(from, to, Fn)
  call assert_notequal(a:from, a:to)
  call assert_equal(a:from, bufnr('%'))
  call a:Fn()
  call assert_equal(a:to, bufnr('%'))
endfunction
