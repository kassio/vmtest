" Setup the vmtest for the given plugin
call vmtest#plugin('vmtest')

" Scope without a custom name
" The scope key will be used as its name
let g:vmtests.vmtest.first_scope = {}

" Similar to the `setup` of some test libraries
function! g:vmtests.vmtest.first_scope._before()
  echo "callback to run before each test\n"
  let self.context_var = 'foo'
endfunction

" Similar to the `teardown` of some test libraries
function! g:vmtests.vmtest.first_scope._after()
  echo "callback to run after each test\n"
endfunction

" A test function on the `first_scope` scope
function! g:vmtests.vmtest.first_scope.test_foo()
  call assert_equal(2, self.context_var)
endfunction

" A test function on the `first_scope` scope
function! g:vmtests.vmtest.first_scope.test_bar()
  call assert_notequal(2, self.context_var)
endfunction

" Exceptions are treated as test errors
function! g:vmtests.vmtest.first_scope.test_treat_exceptions_as_errors()
  call assert_equal(0, g:var_that_does_not_exist_in_any_where)
endfunction

" Scope with a custom name
let g:vmtests.vmtest.second_scope = { '_name': 'My Other Scope' }

" Cannot use scope variable with a test name
function! g:vmtests.vmtest.second_scope._before()
  let self.test_bar = 1
endfunction

" A test function on the `second_scope` scope
function! g:vmtests.vmtest.second_scope.test_bar()
  call assert_equal(1, 1)
endfunction
