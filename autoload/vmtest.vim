scriptencoding utf8

let s:reserved_keys = [
      \ '_tests_counter',
      \ '_name',
      \ '_before',
      \ '_after'
      \ ]

function! vmtest#plugin(name) abort
  if !exists('g:vmtests')
    let g:vmtests =  {}
  end
  if !has_key(g:vmtests, a:name)
    let g:vmtests[a:name] =  {}
  end
endfunction

function! vmtest#run(...) abort
  for test_file in globpath(&runtimepath, 'vmtest/**/*.vim', v:false, v:true)
    execute printf('source %s', test_file)
  endfor

  let g:vmtests._tests_counter = { 'tests': 0, 'failed': 0 }

  if a:0
    let tests = g:vmtests[a:1]
    let level = 1
    echo s:title(a:1, 0)
  else
    let tests = g:vmtests
    let level = 0
  end

  for scope in keys(tests)
    if index(s:reserved_keys, scope) >= 0
      continue
    end

    call s:scope(scope, tests[scope], level)
  endfor

  echo printf("\n\n=> %s Tests Runned.", g:vmtests._tests_counter.tests)
  echo printf('=> %s Tests Succeed, %s Tests Failed.',
        \ g:vmtests._tests_counter.tests - g:vmtests._tests_counter.failed,
        \ g:vmtests._tests_counter.failed
        \ )
endfunction

function! vmtest#quit() abort
  if g:vmtests._tests_counter.failed == 0
    qall!
  else
    cquit
  end
endfunction

function! s:scope(name, dict, level) abort
  echo s:title(a:name, a:level)

  for key in keys(a:dict)
    if index(s:reserved_keys, key) >= 0
      continue
    end

    if type(a:dict[key]) == v:t_dict
      call s:scope(key, a:dict[key], a:level + 1)
    else
      call s:execute(key, a:dict, a:level)
    end
  endfor
endfunction

function! s:title(name, level) abort
  let marker = a:level == 0 ? '=' : '-'
  return printf(
        \ "%s%s> %s\n",
        \ repeat(' ', a:level),
        \ marker,
        \ a:name
        \ )
endfunction

function! s:execute(key, dict, level) abort
  call s:execute_callback(a:dict, '_before')
  call s:execute_test(a:key, a:dict[a:key], a:level)
  call s:execute_callback(a:dict, '_after')
endfunction

function! s:execute_callback(dict, name) abort
  if has_key(a:dict, a:name)
    call a:dict[a:name]()
  end
endfunction

function! s:execute_test(name, Fn, level) abort
  if type(a:Fn) != v:t_func
    call s:type_error()
  end

  let v:errors = []
  let g:vmtests._tests_counter.tests += 1

  try
    call a:Fn()
  catch /.*E116.*/
    " assert_notequal raises an exception when it fails
    " noop
  endtry

  if empty(v:errors)
    echo s:test_result(a:level, a:name, 'Success')
  else
    let g:vmtests._tests_counter.failed += 1
    echo s:test_result(a:level, a:name, 'Failed')
    echo s:test_errors(a:level)
  end
endfunction

function! s:test_result(level, name, result) abort
  return printf('%s » %s: %s', repeat(' ', a:level), a:name, a:result)
endfunction

function! s:test_errors(level)
    return join(map(copy(v:errors), { _idx, error ->
          \   s:error_message(a:level, matchstr(error, '.*: \zs.*'))
          \ }), "\n")
endfunction

function! s:type_error(level, name, value)
    echo s:error_message(
          \ a:level,
          \ '"%s" is a %s, it should be a function',
          \ a:name,
          \ s:type_name(a:value)
          \ )
    cquit
endfunction

function! s:error_message(level, message, ...) abort
  return call('printf', ['%s ! '.a:message, repeat(' ',a:level)] + a:000)
endfunction

function! s:type_name(value) abort
  let types = [
        \ 'number',
        \ 'string',
        \ 'function',
        \ 'list',
        \ 'dictionary',
        \ 'float',
        \ 'boolean',
        \ 'null'
        \ ]

  return types[type(a:value)]
endfunction
