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

  let g:vmtests._tests_counter = { 'tests': 0, 'failed': 0, 'erred': 0 }

  if a:0
    call s:scope(a:1, g:vmtests[a:1], 0)
  else
    for scope in keys(g:vmtests)
      if index(s:reserved_keys, scope) >= 0
        continue
      end

      call s:scope(scope, g:vmtests[scope], 0)
    endfor
  end

  echo '---'
  echo s:summary()
  echo '---'
endfunction

function! vmtest#quit() abort
  if g:vmtests._tests_counter.failed >= 0 || g:vmtests._tests_counter.erred >= 0
    cquit
  else
    qall!
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

function! s:execute(name, dict, level) abort
  let g:vmtests._tests_counter.tests += 1

  call s:execute_callback(a:dict, '_before', a:name)

  if type(a:dict[a:name]) == v:t_func
    call s:execute_test(a:name, a:dict, a:level)
  else
    let g:vmtests._tests_counter.erred += 1
    echo s:type_error(a:level, a:name, a:dict[a:name])
  end

  call s:execute_callback(a:dict, '_after', a:name)
endfunction

function! s:execute_callback(dict, name, test) abort
  if has_key(a:dict, a:name)
    try
      call a:dict[a:name]()
    catch
      call vmtest#logger#error('%s.%s: %s', a:test, a:name, v:exception)
    endtry
  end
endfunction

function! s:execute_test(name, dict, level) abort
  let v:errors = []

  try
    call call(a:dict[a:name], [], a:dict)
  catch /.*E116.*/
    call vmtest#logger#error('%s: %s', a:name, v:exception)
  catch
    echo v:exception
  endtry

  if empty(v:errors)
    echo printf('%s ✓ %s: %s', repeat(' ', a:level), a:name, 'Success')
  else
    let g:vmtests._tests_counter.failed += 1
    echo printf('%s ✗ %s: %s', repeat(' ', a:level), a:name, 'Failed')
    echo s:test_errors(a:level + 2)
  end
endfunction

function! s:test_errors(level) abort
  return join(map(copy(v:errors), { _idx, error ->
        \   s:error_message(a:level, s:clean_error(error))
        \ }), "\n")
endfunction

function! s:clean_error(error) abort
  return matchstr(a:error, '[^:]*: \zs.*')
endfunction

function! s:type_error(level, name, value) abort
  return s:error_message(
        \ a:level,
        \ '"%s" is a %s, it should be a function',
        \ a:name,
        \ s:type_name(a:value)
        \ )
endfunction

function! s:error_message(level, message, ...) abort
  return call('printf', ['%s ! '.a:message, repeat(' ',a:level)] + a:000)
endfunction

function! s:summary() abort
  return join([
        \  printf('=> %s Tests Runned.', g:vmtests._tests_counter.tests),
        \  printf('=> %s Tests Succeed, %s Tests Failed, %s Tests Erred.',
        \  g:vmtests._tests_counter.tests - g:vmtests._tests_counter.failed,
        \  g:vmtests._tests_counter.failed,
        \  g:vmtests._tests_counter.erred)
        \ ], "\n")
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
