function! vmtest#logger#error(string, ...) abort
  call s:log('error', call('printf', extend([a:string], a:000)))
endfunction

function! s:log(type, msg) abort
  call mkdir('log', 'p', 0700)

  redir >> log/vmtest.log
  silent echo printf('[%s]: %s', toupper(a:type), a:msg)
  redir END
endfunction
