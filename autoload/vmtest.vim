let s:reserved_keys = [
      \ '_errors',
      \ '_name',
      \ '_before',
      \ '_after'
      \ ]

function! vmtest#plugin(name)
  if !exists('g:vmtests')
    let g:vmtests =  {}
  end
  if !exists(printf('g:vmtests.%s', a:name))
    let g:vmtests[a:name] =  {}
  end
endfunction

function! vmtest#run(...)
  runtime vmtest/**/*.vim

  let g:vmtests._errors = []
  let l:tests = a:0 ? g:vmtests[a:1] : g:vmtests

  for scope in keys(l:tests)
    if index(s:reserved_keys, scope) >= 0
      continue
    end

    call s:scope(scope, l:tests[scope], 1)
  endfor
endfunction

function! vmtest#quit()
  if empty(g:vmtests._errors)
    qall!
  else
    cquit
  end
endfunction

function! s:scope(name, dict, level)
  echon printf(
        \ "-%s %s\n",
        \ repeat('>', a:level),
        \ get(a:dict, '_name', a:name)
        \ )

  for l:key in keys(a:dict)
    if index(s:reserved_keys, l:key) >= 0
      continue
    end

    if type(a:dict[l:key]) == v:t_dict
      call s:scope(l:key, a:dict[l:key], a:level + 1)
    else
      call s:execute(l:key, a:dict, a:level)
    end
  endfor
endfunction

function! s:execute(key, dict, level)
  call s:execute_callback(a:dict, '_before')
  call s:execute_test(a:key, a:dict[a:key], a:level)
  call s:execute_callback(a:dict, '_after')
endfunction

function! s:execute_callback(dict, name)
  if has_key(a:dict, a:name)
    call a:dict[a:name]()
  end
endfunction

function! s:execute_test(name, Fn, level)
  echon printf('>%s %s: ', repeat('>', a:level), a:name)
  let v:errors = []

  call a:Fn()

  if empty(v:errors)
    echon "Success\n"
  else
    echon "Failed\n"
    for error in v:errors
      call add(g:vmtests._errors, error)
      echon printf("%s» %s\n", repeat(' ', a:level), matchstr(error, ': \zs.*'))
    endfor
  end
endfunction
