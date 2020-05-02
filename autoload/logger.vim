function! logger#error(msg)
  call s:log('error', a:msg)
endfunction

function! s:log(type, msg)
  call mkdir('log', 'p', 0700)

  redir >> log/vmtest.log
  silent echo printf('[%s]: %s', toupper(a:type), a:msg)
  redir END
endfunction
